require 'spec_helper'
require_relative '../../../lib/dlsite_rss/scraper/voice_scraper'

RSpec.describe DlsiteRss::VoiceScraper do
  describe '#scrape', :vcr do
    it 'returns a non-empty ItemCollection with valid items' do
      result = described_class.scrape
      item = result.items.first

      aggregate_failures do
        # コレクション全体
        expect(result).to be_a(DlsiteRss::ItemCollection)
        expect(result.items.size).to be > 1
        expect(result.items.map(&:url)).to all(include('dlsite.com'))
        expect(result.items.map(&:url).uniq.size).to eq(result.items.size)

        # 先頭アイテムの各フィールド
        expect(item.url).to match(%r{https://www\.dlsite\.com/.+/product_id/RJ\d+})
        expect(item.title).to be_a(String)
        expect(item.title).not_to be_empty
        expect(item.maker).to be_a(String)
        expect(item.maker).not_to be_empty
        expect(item.author).to be_a(String)  # 著者なし作品もあるので空文字は許容
        expect(item.description).to be_a(String)
        expect(item.updated_at).to be_a(Time)
        expect(item.updated_at).to be_between(Time.new(2000), Time.now)

        # enclosureはCDNが403を返す環境ではtype/lengthがnilになり得る
        expect(item.enclosure_url).to match(%r{https://.*\.jpg})
        expect(item.enclosure_type).to match(/^image\//).or(be_nil)
        expect(item.enclosure_length).to be_a(Integer).or(be_nil)
      end
    end
  end
end
