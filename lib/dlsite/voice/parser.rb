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

        work_list.each do |work|
          work_name_a_tag = work.search('.work_name').at_css('a')
          url = work_name_a_tag.attribute('href').value

          _img_tag = work.search('.work_thumb_inner').at_css('img')
          enclosure_url = (
            _img_tag.attr('src') || _img_tag.attr('data-src')
          )&.gsub(/^\/\//, "https://")
          enclosure = parse_enclosure(enclosure_url)

          author = work.search('.author').css('a').map(&:inner_text).join(", ")

          contents.push(
            Dlsite::Voice::Content.new(
              url: url,
              title: work_name_a_tag.inner_text,
              maker: work.search('.maker_name').at_css('a').inner_text,
              author: author,
              work_text: work.search('.work_text').inner_text,
              updated_at: parse_updated_at(url),
              enclosure_url: enclosure.url,
              enclosure_type: enclosure.type,
              enclosure_length: enclosure.length,
            )
          )
        end

        contents
      end

      private
      def parse_updated_at(url)
        doc = DlsiteRss::HttpClient.parse_with_nokogiri(url)
        return Time.now unless doc
        updated_at_txt = doc.xpath("//th[contains(text(), '販売日')]/following-sibling::td[1]").inner_text

        if updated_at_txt.include?('時')
          format = '%Y年%m月%d日%t%H時'
        else
          format = '%Y年%m月%d日'
        end

        Time.strptime(updated_at_txt + '+09:00', format + '%z')
      end

      def parse_enclosure(url)
        return Enclosure.new unless url
        response = DlsiteRss::HttpClient.head(url)
        Enclosure.new(url: url, type: response.content_type, length: response.content_length)
      end
    end
  end
end
