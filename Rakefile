require_relative 'lib/dlsite_rss/s3_client'
require_relative 'lib/dlsite/voice'
require_relative 'lib/dlsite/voice/rss'

desc 'run app'
task :run do
  s3_client = DlsiteRss::S3Client.new
  voice_json = "voice.json".freeze

  latest_contents = Dlsite::Voice::Parser.parse
  previous_contents =
    Dlsite::Voice::Contents.load_json(
      s3_client.get(key: voice_json)
    )

  contents = latest_contents.merge(previous_contents).last(30)
  rss = Dlsite::Voice::Rss.make(contents)

  if ENV['PRODUCTION']
    rss.save!
    s3_client.put(key: voice_json, body: contents.to_json)
  else
    puts rss.to_s
  end
end
