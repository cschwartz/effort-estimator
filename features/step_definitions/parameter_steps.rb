Given('the following estimation parameters exist') do |table|
  table.hashes.each do |parameter_attrs|
    project = Project.find(parameter_attrs['project_id']) if parameter_attrs['project_id']

    Parameter.create!(
      title: parameter_attrs['title'],
      project: project
    )
  end
end


Then('I should see the parameter {string}') do |parameter_title|
  within("#parameters") do
    expect(page).to have_content(parameter_title)
  end
end

Then('I should not see the parameter {string}') do |parameter_title|
  within("#parameters") do
    expect(page).not_to have_content(parameter_title)
  end
end

When('I choose to create a new parameter') do
  click_link "Create"
end

When('I choose to edit the parameter {string}') do |parameter_title|
  within("#parameters") do
    parameter_row = find("tr", text: parameter_title)
    within(parameter_row) do
      click_link "Edit"
    end
  end
end

When('I choose to delete the parameter {string}') do |parameter_title|
  within(".parameters") do
    parameter_row = find("tr", text: parameter_title)
    within(parameter_row) do
      click_button "Delete"
    end
  end
end

When('I fill in the parameter form with the following properties') do |table|
  table.hashes.each do |row|
    row.each do |field, value|
      case field
      when 'Title'
        fill_in 'Title', with: value
      end
    end
  end
end

When('I create the parameter') do
  click_button 'Create Parameter'
end

When('I update the parameter') do
  click_button 'Update Parameter'
end
