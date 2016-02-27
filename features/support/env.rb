Bundler.require(:default, :development)

require 'aruba/cucumber'
require 'json_spec/cucumber'

Aruba.configure do |config|
  config.exit_timeout = 20
end
