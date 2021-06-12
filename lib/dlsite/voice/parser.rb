require 'nokogiri'
require 'open-uri'
require 'time'
require 'zlib'
require_relative 'contents'

module Dlsite
  module Voice
    class Parser
      URL = 'https://www.dlsite.com/maniax/new/=/work_type_category/voice'.freeze

      def self.parse
        self.new.parse
      end

      def parse
        html, charset = get_html_with_charset(URL)
        doc = Nokogiri::HTML.parse(html, nil, charset).search('.n_worklist_item')

        contents = Dlsite::Voice::Contents.new
        doc.each do |work|
          node = work.search('.work_name')
          url = node.at_css('a').attribute('href').value
          contents.push(
            Dlsite::Voice::Content.new(
              url: url,
              title: node.at_css('a').inner_text,
              maker: work.search('.maker_name').at_css('a').inner_text,
              author: work.search('.author').at_css('a')&.inner_text,
              work_text: work.search('.work_text').inner_text,
              updated_at: parse_updated_at(url),
            )
          )
          sleep(0.3)
        end

        contents
      end

      private
      def get_html_with_charset(url)
        charset = nil
        options = {
          "accept-encoding" => "gzip"
          }
        html = open(url, options) do |f|
          charset = f.charset
          if f.content_encoding && f.content_encoding.include?(options["accept-encoding"])
            Zlib::GzipReader.wrap(f).read
          else
            f.read
          end
        end

        return html, charset
      rescue => e
        puts "url: " + url.to_s
        raise e
      end

      def parse_updated_at(url)
        html, charset = get_html_with_charset(url)
        doc = Nokogiri::HTML.parse(html, nil, charset)
        updated_at_txt = doc.xpath("//th[contains(text(), '販売日')]/following-sibling::td[1]").inner_text + '+09:00'
        Time.strptime(updated_at_txt, '%Y年%m月%d日%t%H時%z')
      end
    end
  end
end
