require 'net/http'
require 'nokogiri'
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
        response = get_request(URL)
        doc = Nokogiri::HTML.parse(response.body, nil, response.type_params["charset"]).search('.n_worklist_item')

        contents = Dlsite::Voice::Contents.new
        doc.each do |work|
          node = work.search('.work_name')
          url = node.at_css('a').attribute('href').value

          enclosure_url = work.search('.work_thumb_inner').at_css('img').attr('src')&.gsub(/^\/\//, "https://")
          enclosure = parse_enclosure(enclosure_url)

          contents.push(
            Dlsite::Voice::Content.new(
              url: url,
              title: node.at_css('a').inner_text,
              maker: work.search('.maker_name').at_css('a').inner_text,
              author: work.search('.author').at_css('a')&.inner_text,
              work_text: work.search('.work_text').inner_text,
              updated_at: parse_updated_at(url),
              enclosure_url: enclosure.url,
              enclosure_type: enclosure.type,
              enclosure_length: enclosure.length,
            )
          )
          sleep(0.3)
        end

        contents
      end

      class Enclosure < Struct.new(:url, :type, :length, keyword_init: true); end

      private
      def get_request(url)
        uri = URI.parse(url)
        Net::HTTP.get_response(uri)
      rescue => e
        puts "url: " + url.to_s
        raise e
      end

      def parse_updated_at(url)
        response = get_request(url)
        doc = Nokogiri::HTML.parse(response.body, nil, response.type_params["charset"])
        updated_at_txt = doc.xpath("//th[contains(text(), '販売日')]/following-sibling::td[1]").inner_text + '+09:00'
        Time.strptime(updated_at_txt, '%Y年%m月%d日%t%H時%z')
      end

      def parse_enclosure(url)
        if url
          response = get_request(url)
          Enclosure.new(url: url, type: response.content_type, length: response.content_length)
        else
          Enclosure.new(url: nil, type: nil, length: nil)
        end
      end
    end
  end
end
