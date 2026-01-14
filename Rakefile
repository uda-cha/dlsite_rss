require_relative 'lib/dlsite_rss'

desc 'run voice scraping and generate RSS'
task :run, [:category, :env] do |t, args|
  category = args[:category] || 'voice'
  env = args[:env] || 'development'
  DlsiteRss.run(category, env)
end
