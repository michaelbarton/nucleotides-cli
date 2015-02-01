require 'slop'
require 'ncle/s3'

module NCLE
  module FetchData
    class << self

      def execute!
        opts = options
        con  = NCLE::S3.connection(opts)
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

      def fetch_file(connection, options)
        src, dst = options[:s3_url], options[:output_file]
        bucket, file = NCLE::S3.parse_s3_path(src)
        File.open(dst, 'w') do |out|
          out.write connection.directories.get(bucket).files.get(file).body
        end
      end

    end
  end
end
