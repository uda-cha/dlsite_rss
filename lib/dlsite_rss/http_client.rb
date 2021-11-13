require 'httparty'
require 'nokogiri'

module DlsiteRss
  class HttpClient
    class << self
      def get(url)
        HTTParty.get(url, headers: headers)
      rescue => e
        puts "url: " + url.to_s
        raise e
      end

      def head(url)
        HTTParty.head(url, headers: headers)
      rescue => e
        puts "url: " + url.to_s
        raise e
      end

      def parse_with_nokogiri(url)
        res = get(url)
        Nokogiri::HTML.parse(res.body, nil, res.type_params["charset"])
      end

      private
      def headers
        { 'Accept-Encoding' => 'gzip,deflate,identity' }
      end
    end
  end
end
