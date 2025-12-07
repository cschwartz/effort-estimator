# Estimation Session Steps

# Starting a session
When('I choose to start an estimation session') do
  click_link "Start Estimation"
end

When('I start the estimation with {string} as the estimation option') do |estimation_option_title|
  click_link "Start Estimation"
  select estimation_option_title, from: "Estimation option"
  click_button "Start Estimation Session"
end

# Joining a session
When('I join the estimation session') do
  click_button "Join Estimation"
end

When('I choose to join the estimation session') do
  click_button "Join Estimation"
end

# Navigation
Then('I should be on the estimation session page') do
  expect(page).to have_content("Estimation Session")
end

# Current effort
Then('I should see {string} as the current effort') do |effort_title|
  within("#effort-header") do
    expect(page).to have_content(effort_title)
  end
end

Then('I should see {string} in the effort description') do |description|
  within("#effort-header") do
    expect(page).to have_content(description)
  end
end

# Participants
Then('I should see {string} in the participants list') do |email|
  within("#participants-sidebar") do
    expect(page).to have_content(email)
  end
end

Then('I should see {string} next to {string}') do |role_text, email|
  within("#session_participants") do
    participant_row = find(".participant-row", text: email)
    within(participant_row) do
      expect(page).to have_content(role_text)
    end
  end
end

# Category state
Then('I should see the category {string} is active') do |category_title|
  within("#categories-container") do
    category_card = find("#category-#{category_title.parameterize}")
    expect(category_card).to have_css(".category-active-badge", text: "Active")
  end
end

Then('I should see the category {string} is pending') do |category_title|
  within("#categories-container") do
    category_card = find("#category-#{category_title.parameterize}")
    expect(category_card).to have_content("Pending")
  end
end

Then('I should see the category {string} is finalized with value {string}') do |category_title, value|
  within("#categories-container") do
    category_card = find(".collapse", text: category_title)
    expect(category_card).to have_content("Final: #{value}")
  end
end

# Parameter selection
When('I select parameter {string} for category {string}') do |parameter_title, category_title|
  within("#category-#{category_title.parameterize}") do
    select parameter_title, from: "parameter_id"
    click_button "Select Parameter"
  end
end

Then('I should see parameter {string} selected for category {string}') do |parameter_title, category_title|
  within("#category-#{category_title.parameterize}") do
    expect(page).to have_content("per #{parameter_title}")
  end
end

Then('the category {string} should be in voting state') do |category_title|
  within("#category-#{category_title.parameterize}") do
    within("##{category_title.parameterize}-steps") do
      expect(page).to have_css(".step.step-primary", text: "Vote")
    end
  end
end

Then('I should see the parameter selector for category {string}') do |category_title|
  within("#category-#{category_title.parameterize}") do
    expect(page).to have_selector("select[name='parameter_id']")
  end
end

Then('I should not see the parameter selector for category {string}') do |category_title|
  within("#category-#{category_title.parameterize}") do
    expect(page).not_to have_selector("select[name='parameter_id']")
  end
end
