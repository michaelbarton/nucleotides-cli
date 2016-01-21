require 'fog'
require 'nucleotides/credentials'

module Nucleotides
  module S3
    class << self

      def connection
        Fog::Storage.new({
          provider:              'AWS',
          aws_access_key_id:     Nucleotides::Credentials.credential('access_key'),
          aws_secret_access_key: Nucleotides::Credentials.credential('secret_key'),
          region:                Nucleotides::Credentials.credential('region')
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

      def generate_file_path(s3_url, file_path)
        digest = Digest::SHA2.new(256).file(file_path).hexdigest
        time = Time.now.to_i
        File.join(s3_url, "#{digest}-#{time}")
      end

      def get_file(src, dst)
        bucket, file = parse_s3_path(src)
        File.open(dst, 'w') do |out|
          out.write connection.directories.get(bucket).files.get(file).body
        end
      end

    end
  end
end
