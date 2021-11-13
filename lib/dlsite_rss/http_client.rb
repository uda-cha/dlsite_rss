require 'httparty'
require 'nokogiri'

module DlsiteRss
  class HttpClient
    class HttpError < StandardError; end

    NUM_OF_RETRIES = 3

    class << self
      def get(url)
        retry_on_error do
          raise_on_http_error do
            HTTParty.get(url, headers: headers)
          end
        end
      end

      def head(url)
        retry_on_error do
          raise_on_http_error do
            HTTParty.head(url, headers: headers)
          end
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

      def raise_on_http_error(&block)
        res = yield
        raise HttpError.new("HTTP #{res.code}, #{res.request.last_uri}") if res.code >= 400
        res
      end

      def retry_on_error(&block)
        try = 0
        begin
          try += 1
          yield
        rescue => e
          puts e.message
          puts "retrying after 3 seconds..."

          sleep(3)
          retry if try < NUM_OF_RETRIES
          puts "the maximum number of retries has been exceeded!"
          raise e
        end
      end
    end
  end
end
