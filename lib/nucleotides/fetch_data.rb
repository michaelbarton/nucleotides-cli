require 'slop'
require 'nucleotides/s3'

module Nucleotides
  module FetchData
    class << self

      def parse_args(args)
        opts = Slop.parse(args) do |o|
          o.string '-t', '--task-id', 'Nucleotides API task'
        end
        Hash[opts.to_hash.map{|k,v| [k.to_s.gsub('-','_').to_sym, v]}]
      end

      def missing_options(opts)
        required_opts = [:task]
        Nucleotides::Util.missing_options(required_opts, opts)
      end

      def options_valid?(opts)
        if missing_options(opts).empty?
          [:ok, ""]
        else
          [:error, "Missing arguments: " + missing_options(opts).map(&:to_s).join(', ')]
        end
      end

      def execute!(args)
        opts = parse_args(args)

        status, msg = options_valid?(opts)
        if status == :error
          return [status, msg]
        end

        #con  = NCLE::S3.connection(opts)
        #fetch_file(con, opts)
        [:ok, ""]
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
