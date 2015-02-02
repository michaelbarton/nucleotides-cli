module NCLE
  module Util
    class << self

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
