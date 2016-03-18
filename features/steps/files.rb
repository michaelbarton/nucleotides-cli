require 'json'

def last_json
  @document
end

Then(/^the file "(.*?)" should be a valid JSON document$/) do |file_path|
  @document = File.read(File.join("tmp", "aruba", file_path))
  expect{JSON.parse(@document)}.to_not raise_error
end
