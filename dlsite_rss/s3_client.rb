require 'aws-sdk-s3'

module DlsiteRss
  class S3Client
    def put(key:, body:, content_type: "application/json; charset=utf-8", public: false)
      acl = public ? "public-read" : "private"

      s3_client.put_object(
        bucket: bucket,
        key: key,
        body: body,
        content_type: content_type,
        acl: acl,
      )
    end

    def get(key:)
      s3_client.get_object(
        bucket: bucket,
        key: key
      ).body.read
    rescue Aws::S3::Errors::NoSuchKey
      nil
    end

    private
    def s3_client
      @s3_client ||=
        Aws::S3::Client.new(
          region: region,
          access_key_id: access_key_id,
          secret_access_key: secret_access_key
        )
    end

    def bucket
      ENV['BUCKET']
    end

    def region
      ENV['REGION']
    end

    def access_key_id
      ENV['ACCESS_KEY']
    end

    def secret_access_key
      ENV['SECRET_ACCESS_KEY']
    end
  end
end
