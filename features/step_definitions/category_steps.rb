Given('the following estimation categories exist') do |table|
  table.hashes.each do |category_attrs|
    project = Project.find(category_attrs['project_id']) if category_attrs['project_id']

    Category.create!(
      title: category_attrs['title'],
      category_type: category_attrs['category_type'],
      project: project
    )
  end
end


Then('I should see the category {string}') do |category_title|
  within("#categories") do
    expect(page).to have_content(category_title)
  end
end

Then('I should see the category {string} with type {string}') do |category_title, category_type|
  within("#categories") do
    category_row = find("tr", text: category_title)
    within(category_row) do
      expect(page).to have_content(category_type)
    end
  end
end

Then('I should not see the category {string}') do |category_title|
  within("#categories") do
    expect(page).not_to have_content(category_title)
  end
end

Then('I should see the message {string}') do |message|
  expect(page).to have_content(message)
end

When('I choose to create a new category') do
  click_link "Create"
end

When('I choose to edit the category {string}') do |category_title|
  within("#categories") do
    category_row = find("tr", text: category_title)
    within(category_row) do
      click_link "Edit"
    end
  end
end

When('I choose to delete the category {string}') do |category_title|
  within(".categories") do
    category_row = find("tr", text: category_title)
    within(category_row) do
      click_button "Delete"
    end
  end
end

When('I fill in the category form with the following properties') do |table|
  table.hashes.each do |row|
    row.each do |field, value|
      case field
      when 'Title'
        fill_in 'Title', with: value
      when 'Type'
        select value, from: 'Category type'
      end
    end
  end
end

When('I create the category') do
  click_button 'Create Category'
end

When('I update the category') do
  click_button 'Update Category'
end
