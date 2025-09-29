
Given('the following effort nodes exist') do |table|
  table.hashes.each do |effort_attrs|
    project = Project.find(effort_attrs['project_id']) if effort_attrs['project_id']
    parent = Effort.find(effort_attrs['parent_id']) if effort_attrs['parent_id'].present?

    Effort.create!(
      title: effort_attrs['title'],
      description: effort_attrs['description'],
      parent: parent,
      project: project
    )
  end
end

When('I visit the {string} section') do |section|
  case section
  when "Effort Breakdown"
    click_link "Effort Breakdown"
  else
    raise "Unknown section: #{section}"
  end
end

Then('I should see the root effort {string}') do |effort_title|
  within("#effort-tree") do
    expect(page).to have_content(effort_title)
  end
end

When('I expand the effort {string}') do |effort_title|
  within("#effort-tree") do
    effort_link = find("a", text: effort_title)
    effort_node = effort_link.ancestor(".effort-node", match: :first, order: :reverse)
    within(effort_node) do
      toggle_button = find("button[data-action*='reveal#toggle']", match: :first, order: :reverse)
      toggle_button.click
    end
  end
end

Then('I should see the effort {string} at path {string}') do |child_effort, path|
  path_parts = path.split(" > ")

  within("#effort-tree") do
    current_context = page

    path_parts.each do |parent_title|
      parent_link = current_context.find("a", text: parent_title)
      parent_node = parent_link.ancestor(".effort-node", match: :first, order: :reverse)

      current_context = parent_node
    end

    within(current_context) do
      expect(page).to have_content(child_effort)
    end
  end
end

When('I choose to create a new root effort') do
  click_link "Add Root Effort"
end

When('I fill in the effort form with the following properties') do |table|
  properties = table.rows_hash

  fill_in 'Title', with: properties['Title'] if properties.key?('Title')
  fill_in 'Description', with: properties['Description'] if properties.key?('Description')
end

When('I choose to create a new child effort under {string}') do |parent_effort|
  within("#effort-tree") do
    click_link parent_effort
  end

  within("#effort-sidebar") do
    click_link "Add Child"
  end
end

When('I choose to edit the effort {string}') do |effort_title|
  within("#effort-tree") do
    click_link effort_title
  end

  within("#effort-sidebar") do
    click_link "Edit"
  end
end

When('I choose to delete the effort {string}') do |effort_title|
  within("#effort-tree") do
    click_link effort_title
  end

  within("#effort-sidebar") do
    click_button "Delete"
  end
end

Then('I should not see the root effort {string}') do |effort_title|
  within("#effort-tree") do
    expect(page).not_to have_content(effort_title)
  end
end

When('I choose to delete the effort {string} under {string}') do |child_effort, parent_path|
  path_parts = parent_path.split(" > ")

  within("#effort-tree") do
    current_context = page

    path_parts.each do |parent_title|
      parent_link = current_context.find("a", text: parent_title)
      parent_node = parent_link.ancestor(".effort-node")
      current_context = parent_node
    end

    within(current_context) do
      child_link = find("a", text: child_effort)
      child_node = child_link.ancestor(".effort-node")

      within(child_node) do
        click_button "Delete"
      end
    end
  end
end

Then('I should not see the effort {string} at path {string}') do |child_effort, path|
  path_parts = path.split(" > ")

  within("#effort-tree") do
    current_context = page

    path_parts.each do |parent_title|
      parent_link = current_context.find("a", text: parent_title)
      parent_node = parent_link.ancestor(".effort-node")
      current_context = parent_node
    end

    within(current_context) do
      expect(page).not_to have_content(child_effort)
    end
  end
end

Given('I am working on project {string}') do |project_title|
  @project = Project.find_by!(title: project_title)
  visit project_efforts_path(@project)
end

Given('the following effort nodes exist in order') do |table|
  table.hashes.each do |effort_attrs|
    project = Project.find(effort_attrs['project_id']) if effort_attrs['project_id']
    project ||= @project  # Use the current project if no project_id specified

    parent = Effort.find(effort_attrs['parent_id']) if effort_attrs['parent_id'].present?

    effort = Effort.create!(
      title: effort_attrs['title'],
      description: effort_attrs['description'],
      parent: parent,
      project: project
    )

    # Set position if specified
    if effort_attrs['position'].present?
      effort.update!(position: effort_attrs['position'].to_i)
    end
  end
end

When('I enter the {string} section') do |section|
  case section
  when "Effort Breakdown"
    # Already on the page from the "Given I am working on project" step
    # This step is redundant with "I visit the section" but kept for consistency
  else
    raise "Unknown section: #{section}"
  end
end

When('I move {string} to position {int} among its siblings') do |effort_title, position|
  within("#effort-tree") do
    source_link = find("a", text: effort_title)
    source_node = source_link.ancestor(".effort-node")

    drag_handle = source_node.find(".sort-handle")

    parent_ul = source_node.ancestor("ul", match: :first, order: :reverse)

    if position == 1
      drag_handle.drag_to(parent_ul, delay: 0.5)
    else
      siblings = parent_ul.all("li.effort-node")
      target_sibling = siblings[position - 2]
      drag_handle.drag_to(target_sibling, delay: 0.5)
    end
  end
end

Then('I should see the root entries') do |table|
    actual_titles = page.execute_script("
      return Array.from(
        document.querySelectorAll('#effort-tree .effort-node a')
      ).map(
        el => el.textContent.trim()
      )")
    expected_titles = table.hashes.map { |row| row['title'] }

    expect(actual_titles).to eq(expected_titles)
end

When('I move {string} to be a child of {string}') do |source_effort, target_parent|
  within("#effort-tree") do
    source_link = find("a", text: source_effort)
    source_node = source_link.ancestor(".effort-node", match: :first, order: :reverse)
    drag_handle = source_node.find(".sort-handle")

    target_link = find("a", text: target_parent)
    target_parent_node = target_link.ancestor(".effort-node", match: :first, order: :reverse)

    begin
      target_ul = target_parent_node.find("ul.effort-subtree")
      drag_handle.drag_to(target_ul)
    rescue Capybara::ElementNotFound
      drag_handle.drag_to(target_parent_node)
    end
  end
end

When('I create the effort') do
  click_button 'Create Effort'
end

When('I update the effort') do
  click_button 'Update Effort'
end

When('I expand the {string} entry') do |effort_title|
  within("#effort-tree") do
    effort_link = find("a", text: effort_title)
    effort_node = effort_link.ancestor(".effort-node")
    within(effort_node) do
      toggle_button = find("button[data-action*='reveal#toggle']")
      toggle_button.click
    end
  end
end

Then('I should see the following below the path {string}') do |path, table|
  clean_path = path.gsub(/ >$/, '')
  path_parts = clean_path.split(" > ")

  within("#effort-tree") do
    current_context = page

    path_parts.each do |parent_title|
      parent_link = current_context.find("a", text: parent_title)
      parent_node = parent_link.ancestor(".effort-node")
      current_context = parent_node
    end

    table.hashes.each do |row|
      within(current_context) do
        expect(page).to have_content(row['title'])
      end
    end
  end
end

Then('I should not see {string} below the path {string}') do |effort_title, path|
  path_parts = path.split(" > ")

  within("#effort-tree") do
    current_context = page

    path_parts.each do |parent_title|
      parent_link = current_context.find("a", text: parent_title)
      parent_node = parent_link.ancestor(".effort-node")
      current_context = parent_node
    end

    within(current_context) do
      expect(page).to have_no_content(effort_title)
    end
  end
end
