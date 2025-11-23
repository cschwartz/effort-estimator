---
id: steps
feature: Cucumber Step Definitions
priority: High
status: Complete
---

# Cucumber Step Definitions

## Overview

Step definitions are Ruby methods that implement Gherkin steps (Given/When/Then). They connect natural language feature descriptions to the actual code that interacts with the application through the UI. Well-written step definitions are reusable, maintainable, and provide a clean DSL for writing features.

## Purpose

Step definitions:
- **Translate Gherkin** - Convert natural language steps into executable code
- **Navigate UI** - Simulate user interactions through the interface
- **Assert outcomes** - Verify expected behavior visible in the UI
- **Provide abstraction** - Hide implementation details from feature files
- **Enable reuse** - Share common steps across multiple features

## File Organization

```
features/step_definitions/
├── common_steps.rb               # Shared steps across all features
├── project_steps.rb              # Project-specific steps
├── category_steps.rb             # Category-specific steps
├── parameter_steps.rb            # Parameter-specific steps
├── estimation_option_steps.rb    # Estimation option-specific steps
├── effort_steps.rb               # Effort tree-specific steps
└── estimation_session_steps.rb   # Session-specific steps
```

### Organization Principles

**common_steps.rb** - Steps used across multiple features:
- Authentication
- Generic CRUD operations (create, edit, delete)
- Generic assertions (see message, see error)
- Form submission buttons
- Status messages

**Resource-specific files** - Steps unique to a resource:
- Resource-specific navigation
- Complex domain interactions
- Resource-specific assertions
- Custom test data setup

## Core Principles

### 1. Navigate Through UI, Not Paths

Steps should interact with the application as a user would, clicking links and buttons rather than visiting paths directly.

**Good:**
```ruby
When('I visit the projects page') do
  visit root_path  # Start from known location
  click_link "Projects"
end

When('I visit the {string} section') do |section|
  click_link section  # Navigate via UI
end
```

**Avoid:**
```ruby
When('I visit the categories page') do
  visit project_categories_path(@project)  # Bypasses UI navigation
end
```

**Exception:** The `login_as` step visits `root_path` to establish the session after authentication.

### 2. Use Generic Capture Groups, Validate in Step

Use `{string}` or `{int}` capture groups instead of regex alternation. Validate captured values in the step body.

**Good:**
```ruby
When('I choose to create a new {string}') do |resource_type|
  valid_types = ['category', 'parameter', 'project', 'estimation option']
  unless valid_types.include?(resource_type)
    raise "Invalid resource type: '#{resource_type}'. Valid: #{valid_types.join(', ')}"
  end
  click_link "Create"
end
```

**Avoid:**
```ruby
When(/^I choose to create a new (category|parameter|project|estimation option)$/) do |resource_type|
  click_link "Create"
end
```

Rationale:
- Step definitions are easier to read and maintain
- Error messages are clearer when invalid values are used
- Cucumber's step matching is more straightforward

### 3. Use Semantic Scoping

Prefer semantic IDs and classes for scoping. Only add complex matchers when necessary due to UI brittleness, and add comments indicating need for refactoring.

**Good:**
```ruby
Then('I should see the project {string}') do |project_title|
  within("#projects") do  # Semantic ID
    expect(page).to have_content(project_title)
  end
end
```

**Acceptable when needed:**
```ruby
When('I expand the effort {string}') do |effort_title|
  within("#effort-tree") do
    effort_link = find("a", text: effort_title)
    # TODO: Refactor UI to add semantic data attributes for testing
    effort_node = effort_link.ancestor(".effort-node", match: :first, order: :reverse)
    within(effort_node) do
      toggle_button = find("button[data-action*='reveal#toggle']", match: :first, order: :reverse)
      toggle_button.click
    end
  end
end
```

**Avoid:**
```ruby
within("body > div.container > div.row:nth-child(2)") do
  # Too specific, brittle
end
```

### 4. Generalize Steps, Avoid Duplication

Before creating a new step, check if an existing step can be renamed or generalized.

**Good:**
```ruby
When('I choose to edit the {string} {string}') do |resource_type, resource_title|
  valid_types = ['category', 'parameter', 'project', 'estimation option']
  unless valid_types.include?(resource_type)
    raise "Invalid resource type: '#{resource_type}'. Valid: #{valid_types.join(', ')}"
  end

  container_id = resource_type.parameterize(separator: '_').pluralize
  within("##{container_id}") do
    resource_row = find("tr", text: resource_title)
    within(resource_row) do
      click_link "Edit"
    end
  end
end
```

**Balance:** Don't over-generalize if it makes steps unclear or too close to UI manipulation:

```ruby
# Too general - just wrapping Capybara
When('I click {string} within {string}') do |text, selector|
  within(selector) do
    click_link text
  end
end
```

### 5. Avoid Explicit Waits (Code Smell)

Explicit waits (`sleep`) indicate timing issues and should be avoided. Capybara's implicit waiting usually handles async operations.

**Good:**
```ruby
Then('I should see parameter {string} selected for category {string}') do |parameter_title, category_title|
  within("#category-#{category_title.parameterize}") do
    # Capybara automatically waits for content to appear
    expect(page).to have_content(parameter_title)
  end
end
```

**Code Smell:**
```ruby
When('I select parameter {string} for category {string}') do |parameter_title, category_title|
  within("#category-#{category_title.parameterize}") do
    select parameter_title, from: "Parameter"
    click_button "Select"
  end
  sleep 0.5  # CODE SMELL: Indicates timing issue
end
```

If waiting is necessary:
- Use Capybara's built-in waiting (it retries automatically)
- Increase `Capybara.default_max_wait_time` if needed
- Use explicit waits only as last resort and document why

## Step Definition Patterns

### Capture Groups and Parameters

```ruby
# String parameter
When('I visit the {string} section') do |section|
  click_link section
end

# Integer parameter
When('I move {string} to position {int} among its siblings') do |effort_title, position|
  # ...
end

# Multiple parameters
Then('I should see {string} next to {string}') do |role_text, email|
  # ...
end
```

### Data Tables

**Horizontal tables** (key-value pairs):
```ruby
When('I fill in the project form with the following properties') do |table|
  properties = table.rows_hash
  fill_in 'Title', with: properties['Title'] if properties.key?('Title')
  fill_in 'Description', with: properties['Description'] if properties.key?('Description')
end
```

Used in features as:
```gherkin
When I fill in the project form with the following properties
  | Title       | My Project       |
  | Description | My description   |
```

**Vertical tables** (multiple records):
```ruby
Given('the following projects exist') do |table|
  table.hashes.each do |project_attrs|
    Project.create!(
      title: project_attrs['title'],
      description: project_attrs['description']
    )
  end
end
```

Used in features as:
```gherkin
Given the following projects exist
  | title         | description      |
  | Project Alpha | First project    |
  | Project Beta  | Second project   |
```

## Common Step Patterns

### 1. Authentication

```ruby
Given('I am logged in as a user {string} with roles') do |username, table|
  Capybara.session_name = username if @is_multiuser_scenario

  email = "#{username}@example.com"
  password = "a-test-password-for-effort-estimator"
  user = User.create!(
    email: email,
    password: password,
    password_confirmation: password
  )

  login_as user, scope: :user, run_callbacks: false
  visit root_path  # ONLY acceptable path visit - establishes session
end
```

Key aspects:
- Handles both single-user and multi-user scenarios
- Creates user with predictable email pattern
- Uses Warden test helpers for authentication
- Visits root path only to establish session

### 2. Navigation

```ruby
When('I visit the {string} section') do |section|
  valid_sections = ['Effort Breakdown', 'Categories', 'Parameters']
  unless valid_sections.include?(section)
    raise "Invalid section: '#{section}'. Valid: #{valid_sections.join(', ')}"
  end
  click_link section
end

When('I select the project {string}') do |project_title|
  click_link project_title
end
```

Strategies:
- Click-based navigation through UI elements
- Validate section names with clear error messages
- Use semantic link text

### 3. Form Interaction

```ruby
When('I fill in the project form with the following properties') do |table|
  properties = table.rows_hash
  fill_in 'Title', with: properties['Title'] if properties.key?('Title')
  fill_in 'Description', with: properties['Description'] if properties.key?('Description')
end

When('I create the {string}') do |resource_type|
  valid_types = ['category', 'parameter', 'project', 'estimation option', 'effort']
  unless valid_types.include?(resource_type)
    raise "Invalid resource type: '#{resource_type}'. Valid: #{valid_types.join(', ')}"
  end

  display_name = resource_type.split.map.with_index { |word, i| i.zero? ? word.capitalize : word }.join(' ')
  button_text = "Create #{display_name}"
  click_button button_text
end
```

Strategies:
- Use `table.rows_hash` for key-value tables
- Check for key existence before filling (allows optional fields)
- Derive button text from resource type
- Separate filling from submission
- Validate resource types

### 4. Test Data Setup

```ruby
Given('the following projects exist') do |table|
  table.hashes.each do |project_attrs|
    Project.create!(
      title: project_attrs['title'],
      description: project_attrs['description']
    )
  end
end

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
```

Strategies:
- Use `table.hashes` for multiple records
- Look up associations by ID
- Handle optional associations (check for presence)
- Create records directly (bypass UI for setup)

### 5. Assertions with Semantic Scoping

```ruby
Then('I should see the project {string}') do |project_title|
  within("#projects") do  # Semantic container ID
    expect(page).to have_content(project_title)
  end
end

Then('I should see the root effort {string}') do |effort_title|
  within("#effort-tree") do  # Semantic container ID
    expect(page).to have_content(effort_title)
  end
end
```

Strategies:
- Use `within` to scope assertions
- Prefer semantic IDs (`#projects`, `#effort-tree`)
- Avoid overly specific scoping (brittle tests)

### 6. Error and Status Messages

```ruby
Then('I should see the error message {string}') do |error_message|
  expect(page).to have_css("form .alert-error", text: error_message)
end

Then('I should see a status message {string}') do |message|
  expect(page).to have_css(".alert", text: message)
end
```

Strategies:
- Use CSS selectors to find alert containers
- Match exact text for specific messages
- Distinguish between error and success alerts

### 7. Hierarchical Data (Tree Structures)

```ruby
When('I expand the effort {string}') do |effort_title|
  within("#effort-tree") do
    effort_link = find("a", text: effort_title)
    # TODO: Add data-test-id to effort nodes for more robust testing
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
      # TODO: Add semantic data attributes to improve test stability
      parent_node = parent_link.ancestor(".effort-node", match: :first, order: :reverse)
      current_context = parent_node
    end

    within(current_context) do
      expect(page).to have_content(child_effort)
    end
  end
end
```

Strategies:
- Use `ancestor` when necessary (with TODO comments)
- Traverse hierarchies by narrowing context
- Support path notation (e.g., "Parent > Child > Grandchild")
- Document need for UI refactoring

### 8. Multi-User Sessions

```ruby
When('I am acting as the user {string}') do |username|
  expect(@is_multiuser_scenario).to be_truthy
  Capybara.session_name = username
end
```

Used in features:
```gherkin
When I am acting as the user "alice"
And I start the estimation session
When I am acting as the user "bob"
And I join the estimation session
```

Strategies:
- Set `Capybara.session_name` to switch sessions
- Each session maintains separate browser state
- Verify `@is_multiuser_scenario` flag is set
- Coordinate actions across sessions for real-time testing

## Capybara Methods

### Finding Elements

```ruby
# Find by text
find("a", text: "Project Alpha")

# Find by CSS selector
find("#projects")
find(".project")

# Find by data attribute
find("button[data-action='click->toggle#toggle']")

# Find ancestor (when necessary, with TODO)
link.ancestor(".effort-node")

# Find all matching
all(".participant")
```

### Interactions

```ruby
# Click
click_link "Edit"
click_button "Submit"

# Fill in forms
fill_in 'Title', with: 'My Project'
select 'Option', from: 'Dropdown'
check 'Remember me'

# Drag and drop
drag_handle.drag_to(target_element)
```

### Scoping

```ruby
# Scope by semantic ID
within("#projects") do
  click_link "Edit"
end

# Scope by semantic class
within(".current-effort") do
  expect(page).to have_content("Title")
end

# Scope by element
within(project_row) do
  click_button "Delete"
end
```

### Expectations

```ruby
# Positive assertions (with implicit waiting)
expect(page).to have_content("Text")
expect(page).to have_css(".class")
expect(page).to have_link("Link Text")

# Negative assertions
expect(page).not_to have_content("Text")
expect(page).to have_no_css(".class")
```

## Best Practices

### 1. Write Reusable Steps with Validation

**Good:**
```ruby
When('I choose to edit the {string} {string}') do |resource_type, resource_title|
  valid_types = ['category', 'parameter', 'project', 'estimation option']
  unless valid_types.include?(resource_type)
    raise "Invalid resource type: '#{resource_type}'. Valid: #{valid_types.join(', ')}"
  end

  container_id = resource_type.parameterize(separator: '_').pluralize
  within("##{container_id}") do
    resource_row = find("tr", text: resource_title)
    within(resource_row) do
      click_link "Edit"
    end
  end
end
```

**Avoid:**
```ruby
When('I edit the project Alpha') do
  # Hardcoded, not reusable
end
```

### 2. Use Semantic Locators

**Good:**
```ruby
within("#projects") do  # Semantic ID
  click_link "Edit"
end
```

**Avoid:**
```ruby
find("#project_123_edit_link").click  # Database IDs, brittle
```

### 3. Scope Assertions

**Good:**
```ruby
within("#projects") do
  expect(page).to have_content("Project Alpha")
end
```

**Avoid:**
```ruby
expect(page).to have_content("Project Alpha")
# Could match anywhere on the page
```

### 4. Handle Optional Fields

**Good:**
```ruby
fill_in 'Title', with: properties['Title'] if properties.key?('Title')
```

**Avoid:**
```ruby
fill_in 'Title', with: properties['Title']
# Fails if key not present in table
```

### 5. Provide Clear Error Messages

**Good:**
```ruby
valid_sections = ['Effort Breakdown', 'Categories', 'Parameters']
unless valid_sections.include?(section)
  raise "Invalid section: '#{section}'. Valid: #{valid_sections.join(', ')}"
end
```

**Avoid:**
```ruby
click_link section
# Capybara error is less clear about valid options
```

### 6. Document Complex Matchers

```ruby
# Good - with TODO for refactoring
effort_link = find("a", text: effort_title)
# TODO: Add data-test-id="effort-node" to improve test stability
effort_node = effort_link.ancestor(".effort-node", match: :first, order: :reverse)
```

### 7. Parameterize Consistently

```ruby
# Parameterize matches CSS class/ID naming conventions
category_title.parameterize  # "My Category" → "my-category"
category_title.parameterize(separator: '_')  # "My Category" → "my_category"
resource_type.pluralize  # "project" → "projects"
```

## Testing Turbo Interactions

### Turbo Frame Updates

```ruby
When('I choose to edit the project {string}') do |project_title|
  within("#projects") do
    click_link "Edit", match: :first
  end
end

# Form renders in Turbo Frame
And('I fill in the project form with the following properties') do |table|
  # Form is now in the same frame, Capybara waits automatically
  fill_in 'Title', with: table.rows_hash['Title']
end

Then('I should see a status message {string}') do |message|
  # Turbo Stream response updates the page, Capybara waits
  expect(page).to have_css(".alert", text: message)
end
```

### Turbo Stream Broadcasts

```ruby
When('I am acting as the user "alice"')
And('I select parameter {string} for category {string}') do |param, category|
  # Alice selects parameter
end

When('I am acting as the user "bob"')
Then('I should see parameter {string} selected for category {string}') do |param, category|
  # Bob sees the update via Turbo Stream broadcast
  # Capybara's implicit waiting handles the async update
  within("#category-#{category.parameterize}") do
    expect(page).to have_content(param)
  end
end
```

## Debugging Step Definitions

### Print Page Content

```ruby
Then('I pause') do
  puts page.html
  binding.pry  # or binding.debugger
end
```

### Save Screenshot

```ruby
Then('I pause') do
  save_screenshot('debug.png')
  binding.pry
end
```

### Inspect Current Session

```ruby
puts Capybara.current_session.inspect
puts Capybara.session_name  # For multi-user tests
```

### Check Element Presence

```ruby
puts page.has_css?("#element")  # true/false
puts page.has_content?("Text")  # true/false
```

## Common Issues and Solutions

### Element Not Found

**Problem:** `Capybara::ElementNotFound`

**Solutions:**
- Check element selector is correct
- Verify element is visible
- Check if element is in correct Turbo Frame
- Increase `Capybara.default_max_wait_time` if needed (last resort)

### Ambiguous Match

**Problem:** `Capybara::Ambiguous: Ambiguous match, found 2 elements`

**Solutions:**
- Scope with `within` using semantic IDs
- Use `match: :first` if order doesn't matter
- Make selector more specific (add TODO if this indicates UI issue)

### Stale Element Reference

**Problem:** Element found but becomes stale

**Solutions:**
- Don't store elements in variables
- Re-find element before interaction
- Rely on Capybara's automatic retry

### Turbo Frame Not Updating

**Problem:** Form submission doesn't update frame

**Solutions:**
- Verify Turbo Frame IDs match between form and index
- Check JavaScript console for errors
- Ensure controller responds correctly (HTML for errors, Turbo Stream for success)

## Related Documentation

- [features.md](features.md) - Cucumber feature file patterns and conventions
- [testing.md](testing.md) - Overall testing strategy
- [views.md](views.md) - Turbo Frames and Streams implementation
