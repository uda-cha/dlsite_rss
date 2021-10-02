require 'net/http'
require 'nokogiri'

module DlsiteRss
  class HttpClient
    class << self
      def get(url)
        uri = URI.parse(url)
        Net::HTTP.get_response(uri)
      rescue => e
        puts "url: " + url.to_s
        raise e
      end

      def parse_with_nokogiri(url)
        res = get(url)
        Nokogiri::HTML.parse(res.body, nil, res.type_params["charset"])
      end
    end
  end
end
