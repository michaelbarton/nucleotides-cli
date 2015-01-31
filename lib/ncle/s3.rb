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

      def upload_file(connection, local_src_path, s3_dst_path)
        bucket, dst = NCLE::S3.parse_s3_path(s3_dst_path)
        dir  = File.dirname(dst)
        file = File.basename(dst)

        connection.directories.get(dir).create(
          key: file,
          body: File.read(local_src_path))
    end
  end
end
