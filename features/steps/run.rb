require 'curl'
require 'json'
require 'fog'

Given(/^the ncle directory is available on the path$/) do
  ENV['PATH'] = ENV['PATH'] + ":" + File.join(%W|#{File.dirname(__FILE__)} .. .. bin|)
end

When(/^I run the bash command:$/) do |command|
  run_simple("bash -c '#{command}'")
end

Then(/^the corresponding event API entry should contain the keys:$/) do |table|
  sleep 1 # Allow database entry to be written

  id = all_stdout.strip
  response = Curl.get("http://api.nucleotid.es/events/show.json?id=#{id}").body
  @entry = JSON.parse(response)

  table.hashes.each do |row|
    expect(@entry).to include(row['key'])
  end
end

Then(/^the S3 file for the API entry "(.*?)" should exist\.$/) do |key|
  url = @entry[key]
  bucket, path = url.gsub('s3://','').split("/", 2)

  connection = Fog::Storage.new({
    :provider              => 'AWS',
    :aws_access_key_id     => ENV['AWS_ACCESS_KEY'],
    :aws_secret_access_key => ENV['AWS_SECRET_KEY'],
    :region                => 'us-west-1'
  })

  file = connection.directories.get(bucket).files.get(path)
  expect(file).to_not be_nil
end
