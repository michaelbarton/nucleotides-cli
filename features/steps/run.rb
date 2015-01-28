Given(/^the ncle directory is available on the path$/) do
  ENV['PATH'] = ENV['PATH'] + ":" + File.join(%W|#{File.dirname(__FILE__)} .. .. bin|)
end

When(/^I run the bash command:$/) do |command|
  run_simple("bash -c '#{command}'")
end
