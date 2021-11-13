require 'time'
require_relative 'contents'
require_relative '../../dlsite_rss/http_client'

module Dlsite
  module Voice
    class Parser
      class Enclosure < Struct.new(:url, :type, :length, keyword_init: true); end

      URL = 'https://www.dlsite.com/maniax/new/=/work_type_category/voice'.freeze

      def self.parse
        self.new.parse
      end

      def parse
        work_list = DlsiteRss::HttpClient.parse_with_nokogiri(URL).search('.n_worklist_item')

        contents = Dlsite::Voice::Contents.new

        sleep(0.3)

        work_list.each do |work|
          a_tag = work.search('.work_name').at_css('a')
          url = a_tag.attribute('href').value

          img_tag = work.search('.work_thumb_inner').at_css('img')
          enclosure_url = (
            img_tag.attr('src') || img_tag.attr('data-src')
          )&.gsub(/^\/\//, "https://")
          enclosure = parse_enclosure(enclosure_url)

          sleep(1)

          contents.push(
            Dlsite::Voice::Content.new(
              url: url,
              title: a_tag.inner_text,
              maker: work.search('.maker_name').at_css('a').inner_text,
              author: work.search('.author').at_css('a')&.inner_text,
              work_text: work.search('.work_text').inner_text,
              updated_at: parse_updated_at(url),
              enclosure_url: enclosure.url,
              enclosure_type: enclosure.type,
              enclosure_length: enclosure.length,
            )
          )
          sleep(1)
        end

        contents
      end

      private
      def parse_updated_at(url)
        doc = DlsiteRss::HttpClient.parse_with_nokogiri(url)
        updated_at_txt = doc.xpath("//th[contains(text(), '販売日')]/following-sibling::td[1]").inner_text + '+09:00'
        Time.strptime(updated_at_txt, '%Y年%m月%d日%t%H時%z')
      end

      def parse_enclosure(url)
        return Enclosure.new unless url
        response = DlsiteRss::HttpClient.head(url)
        Enclosure.new(url: url, type: response.content_type, length: response.content_length)
      end
    end
  end
end
