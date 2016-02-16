Bundler.require(:default, :development)

require 'aruba/cucumber'
require 'json_spec/cucumber'

Before do
  @aruba_timeout_seconds = 5
end
