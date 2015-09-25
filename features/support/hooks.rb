APP_HOST = ENV['CAPYBARA_APP_HOST'] || "http://busyverse.herokuapp.com"

Capybara.javascript_driver = :webkit
Capybara.app_host = APP_HOST

Capybara::Webkit.configure do |config|
  config.allow_url APP_HOST
end

puts "--- Using application host #{APP_HOST}"
