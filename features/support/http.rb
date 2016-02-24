module HTTP
  require 'curl'

  def self.get(endpoint, query = {})
    url = docker_url + endpoint
    if not query.empty?
      url = query.inject(url + "?") do |string, (k,v)|
        string + k.to_s + '=' + v.to_s
      end
    end
    Curl.get(url)
  end

end
