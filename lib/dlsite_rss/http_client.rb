require 'httparty'
require 'nokogiri'
require 'zlib'

module DlsiteRss
  class HttpClient
    class HttpClientError < StandardError; end
    class HttpNotFoundError < StandardError; end
    class HttpAccessDeniedError < StandardError; end
    class HttpServerError < StandardError; end

    NUM_OF_RETRIES = 3

    class << self
      def get(url)
        sleep(1)

        retry_on_error do
          raise_on_http_error do
            HTTParty.get(url, headers: headers)
          end
        end
      end

      def head(url)
        sleep(1)

        retry_on_error do
          raise_on_http_error do
            HTTParty.head(url, headers: headers)
          end
        end
      end

      def parse_with_nokogiri(url)
        res = get(url)
        return nil unless res
        Nokogiri::HTML.parse(res.body, nil, res.type_params["charset"])
      end

      private
      def headers
        { 'Accept-Encoding' => 'gzip,deflate,identity' }
      end

      def raise_on_http_error(&block)
        res = yield
        if res.code >= 400
          body = if res.headers['content-encoding']&.include?('gzip')
                   Zlib::GzipReader.new(StringIO.new(res.body)).read rescue res.body
                 else
                   res.body
                 end
          puts "[debug] response headers: #{res.headers.to_h}"
          puts "[debug] response body: #{body.to_s.empty? ? "(no body)" : body}"
          error_class = case res.code
                        when 404 then HttpNotFoundError
                        when 403 then HttpAccessDeniedError
                        when 500.. then HttpServerError
                        else HttpClientError
                        end
          raise error_class.new("HTTP #{res.code}, #{res.request.last_uri}")
        end
        res
      end

      def retry_on_error(&block)
        try = 0
        begin
          try += 1
          yield
        rescue HttpNotFoundError => e
          puts e.message
          puts "skip..."
        rescue HttpAccessDeniedError, HttpClientError => e
          raise e
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
