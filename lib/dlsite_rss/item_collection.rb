require 'json'
require_relative 'item'
require_relative 's3_client'

module DlsiteRss
  class ItemCollection
    extend Forwardable
    def_delegators :@items, :each

    attr_reader :items

    def initialize(items: nil, category: nil)
      raise ArgumentError if items && items.any? { |i| !valid_item?(i) }
      @items = items || []
      @category = category
    end

    def s3_key
      raise ArgumentError, "category not set" unless @category
      "#{@category}.json"
    end

    def push(*items)
      items.each do |item|
        raise ArgumentError unless valid_item?(item)
        @items.push(item) if @items.all? { |i| i.url != item.url }
      end
    end

    def last(n)
      sorted_items = @items.sort_by { |i| i.url }.sort_by { |i| i.updated_at }.last(n)
      self.class.new(items: sorted_items, category: @category)
    end

    def merge(others)
      return self unless others
      c = self.class.new(items: @items.dup, category: @category)
      others.each { |o| c.push(o) }
      c
    end

    def load_previous
      return self.class.new(category: @category) unless s3_key
      json = DlsiteRss::S3Client.get(key: s3_key)
      return self.class.new(category: @category) unless json

      items = JSON.parse(json).map { |h| DlsiteRss::Item.from_h(h) }
      self.class.new(items: items, category: @category)
    end

    def to_json
      @items.map(&:to_h).to_json
    end

    def save!
      raise ArgumentError, "s3_key not set" unless s3_key
      DlsiteRss::S3Client.put(
        key: s3_key,
        body: to_json
      )
    end

    private

    def valid_item?(item)
      item.instance_of?(DlsiteRss::Item)
    end
  end
end
