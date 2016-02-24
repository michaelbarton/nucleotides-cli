Given(/^no files in the S3 directory "(.*?)"$/) do |path|
  delete_all_files(path)
end

Then(/^the S3 files should exist:$/) do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end
