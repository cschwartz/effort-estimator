# Project-specific step definitions
# Note: Common CRUD steps (create/edit/delete/see) are in common_steps.rb

Given('the following projects exist') do |table|
  table.hashes.each do |project_attrs|
    Project.create!(
      title: project_attrs['title'],
      description: project_attrs['description']
    )
  end
end

When('I visit the projects page') do
  visit projects_path
end

Then('I should see no projects') do
  expect(page).to have_css("#projects #empty", text: "No existing projects")
end

When('I fill in the project form with the following properties') do |table|
  properties = table.rows_hash
  fill_in 'Title', with: properties['Title'] if properties.key?('Title')
  fill_in 'Description', with: properties['Description'] if properties.key?('Description')
end

When('I select the project {string}') do |link_text|
  click_link link_text
end

When('I visit the project {string} page') do |project_title|
  project = Project.find_by!(title: project_title)
  visit project_path(project)
end

When('I click {string} for {string}') do |action, project_title|
  within(:xpath, "//turbo-frame[@id='projects']//div[contains(., '#{project_title}')]") do
    click_link action
  end
end

Then('I should see project details including the title {string}') do |title|
  expect(page).to have_css(".project .title", text: title)
end

Then('I should see project details including the description {string}') do |description|
  expect(page).to have_css(".project .details .description", text: description)
end
