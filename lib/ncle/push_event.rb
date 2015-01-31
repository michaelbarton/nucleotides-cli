require 'slop'
require 'curl'

require 'ncle/util'

URL = 'http://api.nucleotid.es/events/update'

module NCLE
  module PushEvent
    class << self

      def missing_options(opts)
        required = [:benchmark_id, :benchmark_type_code, :status_code, :event_type_code]
        NCLE::Util.missing_options(required, opts)
      end

      def execute!
        opts = options
        if options_valid?(opts)
          response = post(opts)
          [0, response.body]
        else
          [1, "Missing arguments: " + missing_options(opts).map(&:to_s).join(', ')]
        end
      end

      def options_valid?(opts)
        missing_options(opts).empty?
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
