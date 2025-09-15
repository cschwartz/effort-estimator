Given('I am logged in as a user {string} with roles') do |username, table|
  # Skip authentication for now - in a real app this would set up user authentication
end

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

Then('I should see the project {string}') do |name|
  expect(page).to have_css("tr.project td.title", text: name)
end

Then('I should see no projects') do
  expect(page).to have_css("#projects #empty", text: "No existing projects")
end

When('I choose to create a new project') do
  click_link "Create"
end

When('I choose to edit the project {string}') do |project_name|
  within(find(:xpath, "//tr[td/a[text()='#{project_name}']]")) do
    click_link 'Edit'
  end
end

When('I choose to delete the project {string}') do |project_name|
  within(find(:xpath, "//tr[td/a[text()='#{project_name}']]")) do
    click_button 'Delete'
  end
end

When('I fill in the project form with the following properties') do |table|
  properties = table.rows_hash
  fill_in 'Title', with: properties['Title'] if properties.key?('Title')
  fill_in 'Description', with: properties['Description'] if properties.key?('Description')
end

When('I submit the form') do
  if page.has_button?('Create Project')
    click_button 'Create Project'
  elsif page.has_button?('Update Project')
    click_button 'Update Project'
  else
    click_button 'Submit'
  end
end

Then('I should see the error message {string}') do |error_message|
  expect(page).to have_css("form .error-messages", text: error_message)
end

Then('I should not see the project {string}') do |project_name|
  expect(page).not_to have_css("tr.project td.title", text: project_name)
end

Then('I should see a status message {string}') do |message|
  expect(page).to have_css(".alert", text: message)
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
