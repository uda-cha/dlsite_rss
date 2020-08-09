require 'json'
require 'nokogiri'
require 'open-uri'
require 'rss'
require_relative 'dlsite_rss/s3_client'

def parse_latest_works(url:, updated_at:)
  charset = nil
  html = open(url) do |f|
    charset = f.charset
    f.read
  end

  doc = Nokogiri::HTML.parse(html, nil, charset).search('.n_worklist_item')

  latest_works = {}
  doc.each do |work|
    node = work.search('.work_name')
    title = node.at_css('a').inner_text
    url = node.at_css('a').attribute('href').value
    maker = work.search('.maker_name').at_css('a').inner_text
    author = work.search('.author').at_css('a')&.inner_text
    work_text = work.search('.work_text').inner_text

    latest_works[url.to_sym] = {
      title: title,
      maker: maker,
      author: author,
      work_text: work_text,
      updated_at: updated_at,
    }
  end

  latest_works
end

def target_url
  'https://www.dlsite.com/maniax/new/=/work_type_category/voice'
end

def current_time
  @current_time ||= Time.now.strftime("%Y%m%d_%H%M%S")
end

def make_rss(data:)
  RSS::Maker.make('2.0') do |maker|
    maker.channel.language = 'ja'
    maker.channel.author = "uda-cha"
    maker.channel.updated = current_time
    maker.channel.link = ENV['RSS_URL']
    maker.channel.title = "DLsite RSS Feed(Voice)"
    maker.channel.description = "DLsite RSS Feed(Voice)"

    data.each do |key, val|
      maker.items.new_item do |item|
        item.link = key
        item.title = val[:title]
        item.description = "[#{val[:maker]}#{" / " + val[:author] if val[:author]}] #{val[:work_text]}"
        item.updated = val[:updated_at]
      end
    end
  end
end

def debug_mode?
  mode = ENV.fetch("DEBUG_MODE") { true }
  mode == "false" ? false : true
end

def lambda_handler(event: nil, context: nil)
  s3_client = Dlsite::S3Client.new
  latest_data_basename = "voice_latest_works"

  latest_works = parse_latest_works(url: target_url, updated_at: current_time)
  previous_works_json = s3_client.get(key: "#{latest_data_basename}.json") || "{}"

  previous_works = JSON.parse(previous_works_json, symbolize_names: true)
  latest_works.merge!(previous_works).take(20)
  rss = make_rss(data: latest_works)

  puts debug_mode?.class
  if debug_mode?
    puts rss.to_s
  else
    s3_client.put(key: "voice_rss.xml", body: rss.to_s, content_type: "application/xml", public: true)
    s3_client.put(key: "#{latest_data_basename}.json", body: latest_works.to_json)
  end
end

lambda_handler if __FILE__ == $0
