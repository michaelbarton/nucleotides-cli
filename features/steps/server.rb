def last_json
  @response.body
end

When(/^I get the url "(.*?)"$/) do |endpoint|
  @response = HTTP.get(endpoint)
end
