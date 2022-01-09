require 'json'
require_relative '../../dlsite_rss/s3_client'

module Dlsite
  module Voice
    class Contents
      extend Forwardable
      def_delegators :@contents, :each

      JSON_FILENAME = "voice.json".freeze

      class << self
        def load_json(json)
          return new unless json
          contents = JSON.parse(json).map do |c|
            Content.new(
              url: c['url'],
              title: c['title'],
              maker: c['maker'],
              author: c['author'],
              work_text: c['work_text'],
              updated_at: Time.parse(c['updated_at']),
              enclosure_url: c['enclosure_url'],
              enclosure_type:  c['enclosure_type'],
              enclosure_length: c['enclosure_length']
            )
          end

          new(contents: contents)
        end

        def previous_contents
          json = DlsiteRss::S3Client.get(key: JSON_FILENAME)
          load_json(json)
        end
      end

      def initialize(contents: nil)
        raise ArgumentError if contents && contents.any? { |c| !valid_content?(c) }
        @contents = contents || []
      end

      def initialize_copy(other)
        @contents = @contents.dup
      end

      def push(*contents)
        contents.each do |content|
          raise ArgumentError unless valid_content?(content)
          @contents.push(content) if @contents.all? { |c| c.url != content.url}
        end
      end

      def last(n)
        contents = @contents.sort_by { |c| c.url }.sort_by { |c| c.updated_at }.last(n)
        self.class.new(contents: contents)
      end

      def merge(others)
        return self unless others
        c = self.dup
        others.each { |o| c.push(o) }
        c
      end

      def to_json
        @contents.map(&:to_h).to_json
      end

      def save!
        DlsiteRss::S3Client.put(
          key: JSON_FILENAME,
          body: self.to_json
        )
      end

      private
      def valid_content?(content)
        content.instance_of?(Content)
      end
    end

    class Content < Struct.new(
        :url, :title, :maker, :author, :work_text, :updated_at,
        :enclosure_url, :enclosure_type, :enclosure_length,
        keyword_init: true
      )

      def description
        "[#{maker}#{" / " + author if author}] #{work_text}"
      end
    end
  end
end
