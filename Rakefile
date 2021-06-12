require_relative 'lib/dlsite/voice'
require_relative 'lib/dlsite/voice/rss'

desc 'run app'
task :run do
  latest_contents   = Dlsite::Voice::Parser.parse
  previous_contents = Dlsite::Voice::Contents.previous_contents

  contents = latest_contents.merge(previous_contents).last(30)
  rss = Dlsite::Voice::Rss.make(contents)

  if ENV['PRODUCTION']
    rss.save!
    contents.save!
  else
    puts rss.to_s
  end
end
