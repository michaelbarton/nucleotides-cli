require 'curl'
require 'json'
require 'fog'

When(/^I run the bash command:$/) do |command|
  run_simple("bash -c '#{command}'", false)
end
