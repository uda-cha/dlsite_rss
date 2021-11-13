require 'httparty'
require 'nokogiri'

module DlsiteRss
  class HttpClient
    class HttpError < StandardError; end

    class << self
      def get(url)
        HTTParty.get(url, headers: headers).tap do |res|
          raise HttpError.new("HTTP #{res.code}, #{url}") if res.code >= 400
        end
      end

      def head(url)
        HTTParty.head(url, headers: headers).tap do |res|
          raise HttpError.new("HTTP #{res.code}, #{url}") if res.code >= 400
        end
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
