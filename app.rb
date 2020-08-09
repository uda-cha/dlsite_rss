require_relative 'dlsite_rss/s3_client'
require_relative 'dlsite_rss/voice'

def debug_mode?
  mode = ENV.fetch("DEBUG_MODE") { true }
  mode == "false" ? false : true
end

def main
  current_time = Time.now.strftime("%Y%m%d_%H%M%S")
  s3_client = DlsiteRss::S3Client.new
  latest_contents_file = "voice_latest_contents.json"

  latest_contents = Dlsite::Voice::Parser.parse(executed_at: current_time)
  previous_contents_json = s3_client.get(key: latest_contents_file)
  previous_contents = Dlsite::Voice::Contents.load_json(previous_contents_json)
  latest_contents.merge!(previous_contents).take(20)
  rss = Dlsite::Voice::Rss.make(latest_contents, current_time)

  if debug_mode?
    puts rss.to_s
  else
    s3_client.put(key: "voice_rss.xml", body: rss.to_s, content_type: "application/xml", public: true)
    s3_client.put(key: latest_contents_file, body: latest_contents.to_json)
  end
end

main if __FILE__ == $0
