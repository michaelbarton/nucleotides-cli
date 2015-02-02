require 'slop'
require 'ncle/s3'

module NCLE
  module FetchData
    class << self

      def execute!
        opts = options

        status, msg = options_valid?(opts)
        if status == :error
          return [status, msg]
        end

        con  = NCLE::S3.connection(opts)
        fetch_file(con, opts)
        [:ok, "Downloaded data to: #{opts[:output_file]}"]
      end

      def missing_options(opts)
        required_opts = [:s3_access_key,
                         :s3_secret_key,
                         :s3_url,
                         :output_file]
        NCLE::Util.missing_options(required_opts, opts)
      end

      def options_valid?(opts)
        if missing_options(opts).empty?
          [:ok, ""]
        else
          [:error, "Missing arguments: " + missing_options(opts).map(&:to_s).join(', ')]
        end
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
