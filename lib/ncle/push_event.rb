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

      def xz_compressed?(file_path)
        not (`file #{file_path}` =~ /[Xx][Zz] compressed data/).nil?
      end

      def files_valid?(opts)
        files = [:event, :log, :cgroup]
        files.map{|f| [f, opts["#{f}_file".to_sym]]}.each do |(name, file)|
          if not file.nil?
            if File.exists?(file)
              next if name == :log
              if not xz_compressed?(file)
                return [:error, "The #{name} file should be xz compressed: #{file}"]
              end
            else
              return [:error, "The #{name} file does not exist: #{file}"]
            end
          end
        end
        return [:ok, ""]
      end


      def upload_files(opts)
        file_opts = [:event_file, :log_file, :cgroup_file]
        if file_opts.all?{|f| opts[f].nil? }
          return [:ok, {}]
        end

        con       = NCLE::S3.connection(opts)
        dst       = opts[:s3_url]

        if not NCLE::S3.bucket_exists?(con, dst)
          return [:error, "S3 bucket does not exist: #{dst}"]
        end

        urls = file_opts.inject(Hash.new) do |hash, key|
          if src = opts[key]
            created_file_url = upload_file(con, src, dst)
            hash["#{key}_s3_url".to_sym] = created_file_url
            hash["#{key}_digest".to_sym] = \
              created_file_url.match(/.+\/(.+)-.+/).captures.first
          end
          hash
        end
        [:ok, urls]
      end

      def upload_file(con, src_path, s3_url)
        dst = NCLE::S3.generate_file_path(s3_url, src_path)
        NCLE::S3.upload_file(con, src_path, dst)
        dst
      end


      def execute!
        opts    = options

        status, urls = options_valid?(opts)
        if status == :error
          return [status, urls]
        end

        status, urls = files_valid?(opts)
        if status == :error
          return [status, urls]
        end

        status, urls = upload_files(opts)
        if status == :error
          return [status, urls]
        end

        response = post(opts.merge(urls))
        [:ok, response.body]
      end

      def generate_post_params(opts)
        params = [
          :benchmark_id,
          :benchmark_type_code,
          :status_code,
          :event_type_code,

          :log_file_s3_url,    :log_file_digest,
          :event_file_s3_url,  :event_file_digest,
          :cgroup_file_s3_url, :cgroup_file_digest]
        opts.select{|k, _| params.include? k}
      end

      def post(options)
        params = generate_post_params(options)
        Curl.post(URL, params)
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

    end
  end
end
