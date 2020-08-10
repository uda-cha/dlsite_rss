require 'json'
require 'nokogiri'
require 'open-uri'
require 'rss'

module Dlsite
  module Voice
    module Parser
      URL = 'https://www.dlsite.com/maniax/new/=/work_type_category/voice'.freeze

      def self.parse(executed_at:)
        charset = nil
        html = open(URL) do |f|
          charset = f.charset
          f.read
        end

        doc = Nokogiri::HTML.parse(html, nil, charset).search('.n_worklist_item')

        contents = Dlsite::Voice::Contents.new
        doc.each do |work|
          node = work.search('.work_name')
          contents.add(
            Dlsite::Voice::Content.new(
              url: node.at_css('a').attribute('href').value,
              title: node.at_css('a').inner_text,
              maker: work.search('.maker_name').at_css('a').inner_text,
              author: work.search('.author').at_css('a')&.inner_text,
              work_text: work.search('.work_text').inner_text,
              updated_at: executed_at,
            )
          )
        end

        contents
      end
    end

    class Contents
      def initialize
        @contents = []
      end

      def add(content)
        @contents.push(content) if @contents.all? { |c| c.url != content.url}
      end

      def take(n)
        return @contents if @contents.length <= n
        @contents.sort_by { |c| c.url }.sort_by { |c| c.updated_at }.take(n)
      end

      def each(&block)
        @contents.each { |c| yield c }
      end

      def merge!(others)
        return self unless others
        others.each { |o| self.add(o) }
        self
      end

      def to_json
        @contents.map(&:to_h).to_json
      end

      def self.load_json(json)
        return nil unless json
        JSON.parse(json).map do |c|
          Dlsite::Voice::Content.new(
            url: c.url,
            title: c.title,
            maker: c.maker,
            author: c.author,
            work_text: c.work_text,
            updated_at: c.updated_at,
          )
        end
      end
    end

    class Content < Struct.new(:url, :title, :maker, :author, :work_text, :updated_at, keyword_init: true)
      def description
        "[#{maker}#{" / " + author if author}] #{work_text}"
      end
    end

    module Rss
      def self.make(contents, executed_at)
        RSS::Maker.make('2.0') do |maker|
          maker.channel.language = 'ja'
          maker.channel.author = "uda-cha"
          maker.channel.updated = executed_at
          maker.channel.link = ENV['RSS_URL']
          maker.channel.title = "DLsite RSS Feed(Voice)"
          maker.channel.description = "DLsite RSS Feed(Voice)"

          contents.each do |c|
            maker.items.new_item do |item|
              item.link = c.url
              item.title = c.title
              item.description = c.description
              item.updated = c.updated_at
            end
          end
        end
      end
    end
  end
end
