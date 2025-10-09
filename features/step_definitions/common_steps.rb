# Common step definitions shared across multiple features

include Warden::Test::Helpers

# Authentication
Given('I am logged in as a user {string} with roles') do |username, table|
  user = User.create!(
    email: "#{username}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )

  login_as user, scope: :user, run_callbacks: false
end

# Navigation - generic for all resources using TableComponent
When(/^I choose to create a new (category|parameter|project)$/) do |resource|
    click_link "Create"
end

# Messages and Alerts
Then('I should see the message {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should see the error message {string}') do |error_message|
  expect(page).to have_css("form .alert-error", text: error_message)
end

Then('I should see a status message {string}') do |message|
  expect(page).to have_css(".alert", text: message)
end

# Generic CRUD operations for all resources using TableComponent
When(/^I choose to edit the (category|parameter|project) "([^"]*)"$/) do |resource_type, resource_title|
  container_id = resource_type.pluralize
  within("##{container_id}") do
    resource_row = find("tr", text: resource_title)
    within(resource_row) do
      click_link "Edit"
    end
  end
end

When(/^I choose to delete the (category|parameter|project) "([^"]*)"$/) do |resource_type, resource_title|
  container_class = resource_type.pluralize
  within(".#{container_class}") do
    resource_row = find("tr", text: resource_title)
    within(resource_row) do
      click_button "Delete"
    end
  end
end

Then(/^I should see the (category|parameter|project) "([^"]*)"$/) do |resource_type, resource_title|
  container_id = resource_type.pluralize
  within("##{container_id}") do
    expect(page).to have_content(resource_title)
  end
end

Then(/^I should not see the (category|parameter|project) "([^"]*)"$/) do |resource_type, resource_title|
  container_id = resource_type.pluralize
  within("##{container_id}") do
    expect(page).not_to have_content(resource_title)
  end
end

# Form buttons - generic for all resources
When(/^I create the (category|parameter|project)$/) do |resource_type|
  button_text = "Create #{resource_type.capitalize}"
  click_button button_text
end

When(/^I update the (category|parameter|project)$/) do |resource_type|
  button_text = "Update #{resource_type.capitalize}"
  click_button button_text
end
