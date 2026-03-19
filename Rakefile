require_relative 'lib/dlsite_rss'

desc 'run voice scraping and generate RSS'
task :run, [:category, :env] do |t, args|
  category = args[:category] || 'voice'
  env = args[:env] || 'development'
  DlsiteRss.run(category, env)
end

def scraper_for(category)
  case category
  when 'voice'
    require_relative 'lib/dlsite_rss/scraper/voice_scraper'
    DlsiteRss::VoiceScraper.new
  else
    abort "unknown category: #{category}"
  end
end

def html_cache_path(category)
  "tmp/#{category}_list.html"
end

desc 'fetch list page HTML and save to tmp/<category>_list.html'
task :fetch_html, [:category] do |t, args|
  require_relative 'lib/dlsite_rss/http_client'

  category = args[:category] || 'voice'
  scraper = scraper_for(category)
  cache_path = html_cache_path(category)

  FileUtils.mkdir_p('tmp')
  res = DlsiteRss::HttpClient.get(scraper.class::URL)
  File.write(cache_path, res.body)
  puts "Saved to #{cache_path}"
end

desc 'run scraper against saved HTML without HTTP. Run fetch_html first.'
task :debug_scraper, [:category] do |t, args|
  require 'webmock'
  include WebMock::API

  category = args[:category] || 'voice'
  cache_path = html_cache_path(category)

  Rake::Task[:fetch_html].invoke(category) unless File.exist?(cache_path)

  scraper = scraper_for(category)

  DlsiteRss::HttpClient.define_singleton_method(:sleep) { |_| }
  WebMock.enable!
  stub_request(:any, /.*/).to_return(status: 404)
  stub_request(:get, scraper.class::URL).to_return(body: File.read(cache_path))

  result = scraper.scrape
  output_path = "tmp/#{category}_debug.json"
  File.write(output_path, JSON.pretty_generate(JSON.parse(result.to_json)))
  puts "#{result.items.size} items scraped. Saved to #{output_path}"
end
