require 'fog'

module NCLE
  module S3
    class << self

      def connection(options)
        connection = Fog::Storage.new({
          :provider              => 'AWS',
          :aws_access_key_id     => options[:s3_access_key],
          :aws_secret_access_key => options[:s3_secret_key],
          :region                => options[:s3_region]
        })
      end

      def parse_s3_path(s3_url)
        s3_url.gsub('s3://','').split("/", 2)
      end

      def get_bucket(connection, s3_url)
        bucket, _ = parse_s3_path(s3_url)
        connection.directories.get(bucket)
      end

      def bucket_exists?(connection, s3_url)
        not get_bucket(connection, s3_url).nil?
      end

      def upload_file(connection, src_path, s3_url)
        _, dst_path = parse_s3_path(s3_url)
        get_bucket(connection, s3_url).files.create(
          key: dst_path,
          body: File.read(src_path))
      end

    end
  end
end
