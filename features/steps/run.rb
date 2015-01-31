require 'curl'
require 'json'

Given(/^the ncle directory is available on the path$/) do
  ENV['PATH'] = ENV['PATH'] + ":" + File.join(%W|#{File.dirname(__FILE__)} .. .. bin|)
end

When(/^I run the bash command:$/) do |command|
  run_simple("bash -c '#{command}'")
end

Then(/^the corresponding event API entry should contain the keys:$/) do |table|
  sleep 0.5 # Allow database entry to be written

  id = all_stdout.strip
  response = Curl.get("http://api.nucleotid.es/events/show.json?id=#{id}").body
  entry = JSON.parse(response)
  table.hashes.each do |row|
    expect(entry).to include(row['key'])
  end
end
