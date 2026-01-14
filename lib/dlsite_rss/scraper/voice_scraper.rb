require_relative '../scraper'
require_relative '../item'
require_relative '../http_client'

module DlsiteRss
  class VoiceScraper < Scraper
    URL = 'https://www.dlsite.com/maniax/new/=/work_type_category/voice'.freeze

    def self.category
      'voice'
    end

    class Enclosure < Struct.new(:url, :type, :length, keyword_init: true); end

    protected

    def scrape_items
      work_list = DlsiteRss::HttpClient.parse_with_nokogiri(URL)
                                        .search('.n_worklist_item')

      work_list.map do |work|
        parse_item_from_work_element(work)
      end
    end

    private

    def parse_item_from_work_element(work)
      work_name_a_tag = work.search('.work_name').at_css('a')
      url = work_name_a_tag.attribute('href').value

      _img_tag = work.search('.work_thumb_inner').at_css('img')
      enclosure_url = (
        _img_tag.attr('src') || _img_tag.attr('data-src')
      )&.gsub(/^\/\//, "https://")
      enclosure = parse_enclosure(enclosure_url)

      author = work.search('.author').css('a').map(&:inner_text).join(", ")

      DlsiteRss::Item.new(
        url: url,
        title: work_name_a_tag.inner_text,
        maker: work.search('.maker_name').at_css('a').inner_text,
        author: author,
        description: work.search('.work_text').inner_text,
        updated_at: parse_updated_at(url),
        enclosure_url: enclosure.url,
        enclosure_type: enclosure.type,
        enclosure_length: enclosure.length,
      )
    end

    def parse_updated_at(url)
      doc = DlsiteRss::HttpClient.parse_with_nokogiri(url)
      return Time.now unless doc

      updated_at_txt = doc.xpath("//th[contains(text(), '販売日')]/following-sibling::td[1]")
                           .inner_text

      format = updated_at_txt.include?('時') ? '%Y年%m月%d日%t%H時' : '%Y年%m月%d日'
      Time.strptime(updated_at_txt + '+09:00', format + '%z')
    end

    def parse_enclosure(url)
      return Enclosure.new unless url
      response = DlsiteRss::HttpClient.head(url)
      Enclosure.new(url: url, type: response.content_type, length: response.content_length)
    end
  end
end
