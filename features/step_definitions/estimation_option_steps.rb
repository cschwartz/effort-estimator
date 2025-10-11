# Estimation Option-specific step definitions
# Note: Common CRUD steps (create/edit/delete/see) are in common_steps.rb

Given('the following estimation options exist') do |table|
  table.hashes.each do |option_attrs|
    EstimationOption.create!(
      title: option_attrs['title'] || option_attrs['name']
    )
  end
end

Given('the following estimation options exist with values') do |table|
  table.hashes.each do |row|
    option = EstimationOption.create!(title: row['title'] || row['name'])
    if row['values'].present?
      values = row['values'].split(',').map(&:strip).map(&:to_i)
      values.each do |value|
        option.estimation_option_values.create!(value: value)
      end
    end
  end
end

Given('the following estimation option exists with values') do |table|
  step 'the following estimation options exist with values', table
end

When('I visit the estimation options page') do
  visit estimation_options_path
end

Then('I should see no estimation options') do
  expect(page).to have_css("#estimation_options td#empty")
end

When('I fill in the estimation option form with the following properties') do |table|
  properties = table.rows_hash
  fill_in 'Title', with: properties['Title'] || properties['Name'] if properties.key?('Title') || properties.key?('Name')
end

When('I select the estimation option {string}') do |link_text|
  click_link link_text
end

When('I visit the estimation option {string} page') do |option_title|
  option = EstimationOption.find_by!(title: option_title)
  visit edit_estimation_option_path(option)
end

Then('I should see estimation option details including the name {string}') do |title|
  expect(page).to have_css(".estimation_option .name", text: title)
end

Then('I should see the values {string} for the estimation option') do |values|
  within(".values") do
    values.split(',').map(&:strip).each do |value|
      expect(page).to have_css(".badge", text: value)
    end
  end
end

When('I add the value {string} to the estimation option') do |value|
  click_button 'Add Value'
  # Fill in the newly added value field (last one)
  all('input[placeholder*="Enter value"]').last.set(value)
  click_button 'Update Estimation option'
end

Then('I should see the value {string} in the estimation option') do |value|
  # If not on a page with values, navigate to the last estimation option show page
  unless page.has_css?(".values", wait: 0)
    option = EstimationOption.last
    visit estimation_option_path(option)
  end

  within(".values") do
    expect(page).to have_css(".badge", text: value)
  end
end

Then('I should not see the value {string} in the estimation option') do |value|
  # If not on a page with values, navigate to the last estimation option show page
  unless page.has_css?(".values", wait: 0)
    option = EstimationOption.last
    visit estimation_option_path(option)
  end

  within(".values") do
    expect(page).not_to have_css(".badge", text: value)
  end
end

When('I remove the value {string} from the estimation option') do |value|
  within("#estimation_option_values") do
    # Find the wrapper containing the input with this value
    wrapper = all(".nested-form-wrapper").find { |w| w.find('input[type="number"]').value == value }
    within(wrapper) do
      click_button "Remove"
    end
  end
  click_button 'Update Estimation option'
end
