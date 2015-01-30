require 'slop'
require 'curl'

URL = 'http://api.nucleotid.es/events/update'
REQUIRED_OPTS = [:benchmark_id, :benchmark_type_code, :status_code, :event_type_code]



module NCLE
  module PushEvent
    class << self

      def execute!
        opts = options
        if options_valid?(opts)
          response = post(opts)
          puts response.body
          return true
        else
          puts "Missing arguments: " + missing_options(opts).map(&:to_s).join(', ')
          return false
        end
      end

      def options_valid?(opts)
        missing_options(opts).empty?
      end

      def missing_options(opts)
        REQUIRED_OPTS - opts.keys
      end


      def options
        opts = Slop.parse do |o|
          o.string '-i', '--benchmark-id',        'The benchmark this event corresponds to'
          o.string '-t', '--benchmark-type-code', 'The type of benchmark'
          o.string '-s', '--status-code',         'The outcome of this event'
          o.string '-c', '--event-type-code',     'The type of event'
        end
        Hash[opts.to_hash.map{|k,v| [k.to_s.gsub('-','_').to_sym, v]}]
      end

      def post(options)
        Curl.post(URL, options)
      end
    end
  end
end
