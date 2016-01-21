require 'httparty'

module Nucleotides
  class API
    include HTTParty

    def initialize(uri)
      self.class.base_uri(uri)
    end

    def task(id)
      self.class.get("/tasks/#{id}").parsed_response
    end

  end
end
