require 'slop'
require 'fog'

module NCLE
  module FetchData
    class << self

      def execute!
        opts = options
        con  = connection(opts)
        fetch_file(con, opts)
        true
      end

      def options
        opts = Slop.parse do |o|
          o.string '-a', '--s3-access-key', 'AWS access key'
          o.string '-s', '--s3-secret-key', 'AWS secret key'
          o.string '-u', '--s3-url',        'AWS S3 file url'
          o.string '-r', '--s3-region',     'AWS region'
          o.string '-o', '--output-file',   'Destination for downloaded file'
        end
        Hash[opts.to_hash.map{|k,v| [k.to_s.gsub('-','_').to_sym, v]}]
      end

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

      def fetch_file(connection, options)
        src, dst = options[:s3_url], options[:output_file]
        bucket, file = parse_s3_path(src)
        File.open(dst, 'w') do |out|
          out.write connection.directories.get(bucket).files.get(file).body
        end
      end

    end
  end
end
