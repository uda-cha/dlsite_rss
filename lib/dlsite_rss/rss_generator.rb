require 'rss'
require_relative 's3_client'

module DlsiteRss
  class RssGenerator
    attr_reader :rss

    def self.make(items, channel_title:, channel_description:, language: 'ja')
      new(items, channel_title: channel_title,
                 channel_description: channel_description,
                 language: language).make
    end

    def initialize(items, channel_title:, channel_description:, language: 'ja')
      @items = items
      @channel_title = channel_title
      @channel_description = channel_description
      @language = language
    end

    def make
      rss_obj = ::RSS::Maker.make('2.0') do |maker|
        maker.channel.language = @language
        maker.channel.author = "uda-cha"
        maker.channel.updated = Time.now
        maker.channel.link = ENV['RSS_URL']
        maker.channel.title = @channel_title
        maker.channel.description = @channel_description

        @items.each do |item|
          maker.items.new_item do |rss_item|
            rss_item.link = item.url
            rss_item.title = item.title
            rss_item.description = format_description(item)
            rss_item.updated = item.updated_at
            rss_item.enclosure.url = item.enclosure_url
            rss_item.enclosure.type = item.enclosure_type
            rss_item.enclosure.length = item.enclosure_length
          end
        end
      end

      @rss = rss_obj
      self
    end

    def to_s
      @rss.to_s
    end

    def save!(s3_key:)
      raise ArgumentError, "rss not generated" unless @rss
      DlsiteRss::S3Client.put(
        key: s3_key,
        body: to_s,
        content_type: "application/xml",
        public: true,
      )
    end

    private

    def format_description(item)
      prefix_parts = []
      prefix_parts << item.maker if item.maker && !item.maker.empty?
      
      if item.author && !item.author.empty?
        prefix_parts << item.author
      end
      
      if prefix_parts.empty?
        item.description
      else
        "[#{prefix_parts.join(' / ')}] #{item.description}"
      end
    end
  end
end
