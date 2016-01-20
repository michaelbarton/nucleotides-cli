require 'curl'
require 'json'
require 'fog'

When(/^I run the bash command:$/) do |command|
  run_simple("bash -c '#{command}'", false)
end

Given(/^the nucleotides directory is available on the path$/) do
  ENV['PATH'] = ENV['PATH'] + ":" + File.join(%W|#{File.dirname(__FILE__)} .. .. bin|)
end
