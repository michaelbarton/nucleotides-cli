Bundler.require(:default, :development)
require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 5
end
