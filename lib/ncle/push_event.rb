require 'slop'
require 'curl'

require 'ncle/util'
require 'ncle/s3'

URL = 'http://api.nucleotid.es/events/update'

module NCLE
  module PushEvent
    class << self

      def missing_options(opts)
        required_opts = [:benchmark_id,
                         :benchmark_type_code,
                         :status_code,
                         :event_type_code]
        NCLE::Util.missing_options(required_opts, opts)
      end

      def options_valid?(opts)
        if missing_options(opts).empty?
          [:ok, ""]
        else
          [:error, "Missing arguments: " + missing_options(opts).map(&:to_s).join(', ')]
        end
      end

      def upload_files(opts)
        file_opts = [:event_file, :log_file, :cgroup_file]
        con       = NCLE::S3.connection(opts)
        dst       = opts[:s3_url]

        if not NCLE::S3.bucket_exists?(con, dst)
          return [:error, "S3 bucket does not exist: #{dst}"]
        end

        urls = file_opts.inject(Hash.new) do |hash, key|
          if src = opts[key]
            key, created_file_url = upload_file(con, src, dst)
            hash[key] = created_file_url
          end
          hash
        end
        [:ok, urls]
      end

      def upload_file(con, src_path, s3_url)
        destination_url = File.join(s3_url, create_file_name(src_path))
        NCLE::S3.upload_file(con, src_path, destination_url)
        destination_url
      end

      def create_file_name(file_path)
        "dummy"
      end

      def execute!
        opts = options

        status, msg = options_valid?(opts)
        if status == :error
          return [status, msg]
        end

        status, urls = upload_files(opts)
        if status == :error
          return [status, msg]
        end


        response = post(opts)
        [0, response.body]
      end

      def options
        opts = Slop.parse do |o|
          o.string '-i', '--benchmark-id',        'The benchmark this event corresponds to'
          o.string '-t', '--benchmark-type-code', 'The type of benchmark'
          o.string '-s', '--status-code',         'The outcome of this event'
          o.string '-c', '--event-type-code',     'The type of event'

          o.string '-a', '--s3-access-key',       'AWS access key'
          o.string '-x', '--s3-secret-key',       'AWS secret key'
          o.string '-u', '--s3-url',              'AWS S3 file url'
          o.string '-r', '--s3-region',           'AWS region'

          o.string '-e', '--event-file',          'Path to event file to upload'
          o.string '-l', '--log-file',            'Path to log file to upload'
          o.string '-g', '--cgroup-file',         'Path to cgroup log file to upload'
        end
        Hash[opts.to_hash.map{|k,v| [k.to_s.gsub('-','_').to_sym, v]}]
      end

      def post(options)
        Curl.post(URL, options)
      end
    end
  end
end
