require 'json'

def last_json
  @document
end

Then(/^the file "(.*?)" should be a valid JSON document$/) do |file_path|
  @document = File.read(File.join("tmp", "aruba", file_path))
  expect{JSON.parse(@document)}.to_not raise_error
end


Given(/^I copy the example data files:$/) do |table|
  table.raw.each do |row|
    dst = ENV['TMPDIR'] + "/" + row[1]
    src = "example_data/" + row[0]

    dir = File.dirname(dst)
    FileUtils.mkdir_p(dir)
    FileUtils.cp(src, dst)
  end
end


Given(/^I copy the example data files to their SHA256 named versions:$/) do |table|
  table.raw.each do |row|
    src = "example_data/" + row[0]
    dir = ENV['TMPDIR'] + "/" + row[1]

    sha256 = OpenSSL::Digest::SHA256.new
    digest = sha256.hexdigest(File.read(src))
    dst = dir + "/" + digest[0..9]

    FileUtils.mkdir_p(dir)
    FileUtils.cp(src, dst)
  end
end
