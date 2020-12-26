require_relative 'dlsite_rss/s3_client'
require_relative 'dlsite_rss/voice'

def debug_mode?
  mode = ENV.fetch("DEBUG_MODE") { true }
  mode == "false" ? false : true
end

def main
  s3_client = DlsiteRss::S3Client.new
  voice_json = "voice.json".freeze

  latest_contents = Dlsite::Voice::Parser.parse
  previous_contents =
    Dlsite::Voice::Contents.load_json(
      s3_client.get(key: voice_json)
    )

  contents = latest_contents.merge(previous_contents).last(30)
  rss = Dlsite::Voice::Rss.make(contents)

  if debug_mode?
    puts rss.to_s
  else
    s3_client.put(key: "voice_rss.xml", body: rss.to_s, content_type: "application/xml", public: true)
    s3_client.put(key: voice_json, body: contents.to_json)
  end
end

main if __FILE__ == $0
