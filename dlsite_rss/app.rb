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

def put_to_s3(key:, body:, content_type: "application/json; charset=utf-8")
  s3_client.put_object(
    bucket: ENV['BUCKET'],
    key: key,
    body: body,
    content_type: content_type
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
    title = node.css('a').inner_text
    url = node.css('a').attribute('href').value

    latest_works[url] = { title: title, updated_at: updated_at }
  end

  latest_works
end

def lambda_handler(event: nil, context: nil)
  rss_url = ENV['RSS_URL']
  target_url = 'https://www.dlsite.com/maniax/new/=/work_type_category/voice'
  latest_data_basename = "voice_latest_works"
  updated_at = Time.now.strftime("%Y%m%d_%H%M%S")

  latest_works = parse_latest_works(url: target_url, updated_at: updated_at)
  previous_works = JSON.parse(
    begin
      s3_client.get_object(
        bucket: ENV['BUCKET'],
        key: "#{latest_data_basename}.json"
      ).body.read
    rescue Aws::S3::Errors::NoSuchKey
      "{}"
    end
  )

  latest_works.merge!(previous_works).take(20)

  rss = RSS::Maker.make('2.0') do |maker|
    maker.channel.language = 'ja'
    maker.channel.author = "uda-cha"
    maker.channel.updated = updated_at
    maker.channel.link = rss_url
    maker.channel.title = "DLsite RSS Feed(Voice)"
    maker.channel.description = "DLsite RSS Feed(Voice)"

    latest_works.each do |key, val|
      maker.items.new_item do |item|
        item.link = key
        item.title = val[:title]
        item.updated = val[:updated_at]
      end
    end
  end

  put_to_s3(key: "voice_rss.xml", body: rss.to_s, content_type: "application/xml")
  put_to_s3(key: "#{latest_data_basename}.json", body: latest_works.to_json)
  put_to_s3(key: "#{latest_data_basename}_#{updated_at}.json", body: latest_works.to_json)
end

lambda_handler if __FILE__ == $0
