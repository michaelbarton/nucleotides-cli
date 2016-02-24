Given(/^no files in the S3 directory "(.*?)"$/) do |path|
  delete_all_files(path)
end

Then(/^the S3 bucket "(.*?)" should contain the files:$/) do |bucket, table|
  files = list_all_files(bucket)
  table.raw.each do |(row)|
    expect(files).to include(row)
  end
end
