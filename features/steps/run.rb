def get_binary_path(binary)
  File.join(%W|#{File.dirname(__FILE__)} .. .. bin| << binary)
end

When(/^I run the script `(.*)`$/) do |binary|
  run_simple(unescape(get_binary_path(binary)), false)
end
