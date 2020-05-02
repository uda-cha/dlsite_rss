require 'aws-sdk-s3'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'rss'

def s3_client
  @s3_client ||=
    Aws::S3::Client.new(
      region: ENV['REGION'],
      access_key_id: ENV['ACCESS_KEY'],
      secret_access_key: ENV['SECRET_ACCESS_KEY']
    )
end

def put_to_s3(key:, body:, content_type: "application/json; charset=utf-8", public: false)
  acl = public ? "public-read" : "private"

  s3_client.put_object(
    bucket: ENV['BUCKET'],
    key: key,
    body: body,
    content_type: content_type,
    acl: acl,
  )
end

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
    author = work.search('.author').at_css('a').inner_text
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

def lambda_handler(event: nil, context: nil)
  rss_url = ENV['RSS_URL']
  latest_data_basename = "voice_latest_works"

  latest_works = parse_latest_works(url: target_url, updated_at: current_time)
  previous_works_json =
    begin
      s3_client.get_object(
        bucket: ENV['BUCKET'],
        key: "#{latest_data_basename}.json"
      ).body.read
    rescue Aws::S3::Errors::NoSuchKey
      "{}"
    end
  previous_works = JSON.parse(previous_works_json, symbolize_names: true)
  latest_works.merge!(previous_works).take(20)

  rss = RSS::Maker.make('2.0') do |maker|
    maker.channel.language = 'ja'
    maker.channel.author = "uda-cha"
    maker.channel.updated = current_time
    maker.channel.link = rss_url
    maker.channel.title = "DLsite RSS Feed(Voice)"
    maker.channel.description = "DLsite RSS Feed(Voice)"

    latest_works.each do |key, val|
      maker.items.new_item do |item|
        item.link = key
        item.title = val[:title]
        item.description = "[#{val[:maker]} / #{val[:author]}] #{val[:work_text]}"
        item.updated = val[:updated_at]
      end
    end
  end

  put_to_s3(key: "voice_rss.xml", body: rss.to_s, content_type: "application/xml", public: true)
  put_to_s3(key: "#{latest_data_basename}.json", body: latest_works.to_json)
  put_to_s3(key: "#{latest_data_basename}_#{current_time}.json", body: latest_works.to_json)
end

lambda_handler if __FILE__ == $0
