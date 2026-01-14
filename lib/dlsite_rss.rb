require 'json'
require 'time'
require_relative 'dlsite_rss/scraper/voice_scraper'
require_relative 'dlsite_rss/item_collection'
require_relative 'dlsite_rss/rss_generator'

module DlsiteRss
  class << self
    def run(category = 'voice', env = 'development')
      unless ['development', 'production'].include?(env)
        raise ArgumentError, "env must be 'development' or 'production', got: #{env}"
      end

      scraper = case category
                when 'voice'
                  DlsiteRss::VoiceScraper.new
                when 'manga'
                  raise NotImplementedError, "manga category not yet supported"
                else
                  raise ArgumentError, "unknown category: #{category}"
                end

      latest_items = scraper.scrape
      previous_items = DlsiteRss::ItemCollection.new(category: scraper.category).load_previous
      merged = latest_items.merge(previous_items).last(100)

      channel_title = "DLsite RSS Feed(#{scraper.category.capitalize})"
      channel_description = "DLsite RSS Feed(#{scraper.category.capitalize})"

      rss = DlsiteRss::RssGenerator.make(
        merged.items,
        channel_title: channel_title,
        channel_description: channel_description
      )

      rss_key = "#{scraper.category}_rss.xml"

      if env == 'production'
        rss.save!(s3_key: rss_key)
        merged.save!
      else
        puts rss.to_s
      end
    end
  end
end
