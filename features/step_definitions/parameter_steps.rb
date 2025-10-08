# Parameter-specific step definitions
# Note: Common CRUD steps are in common_steps.rb

Given('the following estimation parameters exist') do |table|
  table.hashes.each do |parameter_attrs|
    project = Project.find(parameter_attrs['project_id']) if parameter_attrs['project_id']

    Parameter.create!(
      title: parameter_attrs['title'],
      project: project
    )
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
