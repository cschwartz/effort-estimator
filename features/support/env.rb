# frozen_string_literal: true

require "cucumber/rails"
require "selenium-webdriver"
require "rspec/expectations"

World(RSpec::Matchers)

driver = ENV["CI"].present? ? :selenium_chrome_headless : :selenium_chrome

Capybara.default_driver = driver
Capybara.javascript_driver = driver

ActionController::Base.allow_rescue = false
begin
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do
  page.driver.browser.manage.window.resize_to(1920, 1080)
end

Cucumber::Rails::Database.javascript_strategy = :truncation

# Keep browser open for debugging when @debug tag is used
After('@debug') do |scenario|
  puts "Debug mode: Browser will stay open. Press Enter to continue..."
  binding.break
end
