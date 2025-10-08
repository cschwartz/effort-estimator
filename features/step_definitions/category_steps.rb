# Category-specific step definitions
# Note: Common CRUD steps are in common_steps.rb

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

Then('I should see the category {string} with type {string}') do |category_title, category_type|
  within("#categories") do
    category_row = find("tr", text: category_title)
    within(category_row) do
      expect(page).to have_content(category_type)
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
