module NCLE
  module Util
    class << self

      def missing_options(required, given)
        given.select{|k,v| required.include?(k) and v.nil?}.keys
      end

    end
  end
end
