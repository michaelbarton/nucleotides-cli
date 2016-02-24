When(/^I get the url "(.*?)"$/) do |endpoint|
  @document = HTTP.get(endpoint).body
end
