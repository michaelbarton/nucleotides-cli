require 'docker'

Given(/^the image "(.*?)" is not installed$/) do |image|
  Docker::Image.get(image).remove(force: true) if Docker::Image.exist?(image)
end
