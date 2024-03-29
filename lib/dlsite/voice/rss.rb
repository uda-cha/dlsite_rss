require 'rss'
require_relative '../../dlsite_rss/s3_client'

module Dlsite
  module Voice
    class Rss
      extend Forwardable
      def_delegators :@rss, :to_s

      def self.make(contents)
        rss = ::RSS::Maker.make('2.0') do |maker|
          maker.channel.language = 'ja'
          maker.channel.author = "uda-cha"
          maker.channel.updated = Time.now
          maker.channel.link = ENV['RSS_URL']
          maker.channel.title = "DLsite RSS Feed(Voice)"
          maker.channel.description = "DLsite RSS Feed(Voice)"

          contents.each do |c|
            maker.items.new_item do |item|
              item.link = c.url
              item.title = c.title
              item.description = c.description
              item.updated = c.updated_at
              item.enclosure.url = c.enclosure_url
              item.enclosure.type = c.enclosure_type
              item.enclosure.length = c.enclosure_length
            end
          end
        end

        new(rss)
      end

      def initialize(rss)
        @rss = rss
      end

      def save!
        DlsiteRss::S3Client.put(
          key: "voice_rss.xml",
          body: self.to_s,
           content_type: "application/xml",
           public: true,
        )
      end
    end
  end
end
