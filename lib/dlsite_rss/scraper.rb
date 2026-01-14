require_relative 'item_collection'

module DlsiteRss
  class Scraper
    def self.category
      raise NotImplementedError, "subclass must define category"
    end

    def category
      self.class.category
    end

    def self.scrape
      new.scrape
    end

    def scrape
      item_collection = DlsiteRss::ItemCollection.new(category: category)

      scrape_items.each do |item|
        item_collection.push(item)
      end

      item_collection
    end

    protected

    def scrape_items
      raise NotImplementedError, "subclass must implement scrape_items"
    end
  end
end
