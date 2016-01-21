require 'nucleotides/fetch_data'

module Nucleotides
  module Util
    class << self

      COMMANDS = {
        'fetch-data' => Nucleotides::FetchData
      }

      def subcommand(name)
        COMMANDS[name]
      end

      def execute!(args)
        subcommand(args.shift).execute!(args)
      end

      def missing_options(required, given)
        given.select{|k,v| required.include?(k) and v.nil?}.keys
      end

      def finish(status, msg)
        if status == :ok
          STDOUT.puts(msg + "\n")
          exit(0)
        else
          STDERR.puts(msg + "\n")
          exit(1)
        end
      end

    end
  end
end
