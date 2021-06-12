require_relative 'lib/dlsite/voice'

desc 'run app'
task :run do
  contents = Dlsite::Voice.make_current_contents
  rss = Dlsite::Voice::Rss.make(contents)

  if ENV['PRODUCTION']
    rss.save!
    contents.save!
  else
    puts rss.to_s
  end
end
