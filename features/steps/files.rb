require 'json'

def last_json
  @json
end

Then(/^the file "(.*?)" should be a valid JSON document$/) do |file_path|
  @json = File.read(file_path)
  expect{JSON.parse(@json)}.to_not raise_error
end
