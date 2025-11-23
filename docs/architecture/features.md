# Cucumber Features

## Overview

Cucumber features provide acceptance-level testing using Behavior-Driven Development (BDD) methodology. Features are written in Gherkin syntax, describing application behavior from a user's perspective. They serve as executable specifications that verify user stories are correctly implemented.

## Purpose

Feature tests:
- **Validate user stories** - Verify acceptance criteria are met
- **Document behavior** - Serve as living documentation of features
- **Test end-to-end flows** - Exercise full stack from browser to database
- **Drive implementation** - Guide development through outside-in TDD
- **Ensure regression protection** - Catch breaking changes across the application

## File Organization

```
features/
├── *.feature                          # Feature files (Gherkin)
├── step_definitions/                  # Step implementations
│   ├── common_steps.rb               # Shared steps across features
│   ├── [resource]_steps.rb           # Resource-specific steps
│   └── estimation_session_steps.rb   # Session-specific steps
└── support/
    └── env.rb                         # Test environment configuration
```

## Feature Structure

### Basic Template

```gherkin
@javascript @US-XX
Feature: [Feature Name]
  As a [role]
  I want to [action]
  So that [benefit]

  @US-XX-AC-YY
  Scenario: [Scenario description]
    Given [preconditions]
    When [action]
    Then [expected outcome]
```

### Key Elements

#### Feature Tags
- `@javascript` - Enables JavaScript/browser testing with Selenium
- `@US-XX` - Maps feature to user story ID
- `@multiuser` - Enables multi-user session testing (for real-time collaboration)

#### Scenario Tags
- `@US-XX-AC-YY` - Maps scenario to specific acceptance criteria
- Multiple tags indicate scenario tests multiple ACs

#### Gherkin Keywords

**Given** - Establishes context and preconditions
- Creating test data
- Setting up user authentication
- Navigating to starting location

**When** - Describes the action being tested
- User interactions (clicks, form submissions)
- Navigation
- State changes

**Then** - Asserts expected outcomes
- Visible content
- State changes
- Database changes (tested indirectly through UI)

**And** - Chains multiple Given/When/Then statements
- Improves readability
- Groups related steps

**Rule** - Groups related scenarios under a business rule
- Organizes scenarios by feature aspect (e.g., "Create projects", "Update projects")
- Optional but recommended for readability

## Naming Conventions

### Feature Files
- Use snake_case
- Name matches the primary resource or feature: `project_management.feature`
- Name reflects user story subject: `estimation_session.feature`

### Scenarios
- Use descriptive names that explain the test case
- Good: "Create new project"
- Good: "Create project without title"
- Avoid: "Test 1", "Happy path"

### Steps
- Use present tense for actions
- Use natural language
- Be specific but avoid implementation details

## Common Patterns

### Authentication Pattern

```gherkin
Given I am logged in as a user "project-manager" with roles
  | role          |
  | projects:list |
  | projects:view |
```

This pattern:
- Creates a user with email `project-manager@example.com`
- Assigns specified roles
- Logs the user in
- Is defined in `common_steps.rb`

### Test Data Pattern

```gherkin
And the following projects exist
  | id | title         | description                 |
  |  1 | Project Alpha | First project in the system |
  |  2 | Project Beta  | Second project for testing  |
```

This pattern:
- Uses tables for multiple records
- Defines attributes explicitly
- Creates records in the database
- Uses FactoryBot under the hood

### Navigation Pattern

```gherkin
When I visit the projects page
And I select the project "Project Alpha"
And I visit the "Categories" section
```

This pattern:
- Uses semantic navigation steps
- Abstracts URL details
- Follows user mental model

### Form Interaction Pattern

```gherkin
When I choose to create a new project
And I fill in the project form with the following properties
  | Title       | My First Project                      |
  | Description | A sample project for testing purposes |
And I create the project
```

This pattern:
- Breaks form interaction into steps
- Uses tables for field values
- Separates form filling from submission

### Assertion Pattern

```gherkin
Then I should see a status message "Project was successfully created"
And I should see the project "My First Project"
And I should not see the project "Old Project"
```

This pattern:
- Asserts positive outcomes
- Asserts negative outcomes (what shouldn't be visible)
- Checks both success messages and data presence

### Turbo Frame Pattern (Inline Editing)

```gherkin
When I choose to edit the project "Project Alpha"
And I fill in the project form with the following properties
  | Title | Updated Title |
And I update the project
Then I should see a status message "Project was successfully updated"
And I should see the project "Updated Title"
```

This pattern:
- Tests inline editing via Turbo Frames
- Validates both form rendering and list updates
- Tests Turbo Stream responses

## Multi-User Testing

For features requiring real-time collaboration (e.g., estimation sessions):

```gherkin
@javascript @multiuser
Feature: Estimation Session

  Scenario: Multiple users see updates in real-time
    Given I am logged in as a user "alice" with roles
      | role                            |
      | estimation_sessions:participate |
    And I am logged in as a user "bob" with roles
      | role                            |
      | estimation_sessions:participate |
    When I am acting as the user "alice"
    And I start the estimation session
    When I am acting as the user "bob"
    And I join the estimation session
    Then I am acting as the user "alice"
    And I should see "bob@example.com" in the participants list
```

Key aspects:
- `@multiuser` tag enables multiple browser sessions
- Each user gets a separate Capybara session
- `I am acting as the user "username"` switches between sessions
- Tests real-time updates via Turbo Streams

## Testing Strategy

### What to Test

**Business Logic Flows**
- Complete user workflows from start to finish
- Valid data submission and success paths
- Invalid data submission and error handling
- Edge cases and boundary conditions

**User Interactions**
- Form submissions
- Navigation between pages
- Inline editing via Turbo Frames
- Real-time updates via Turbo Streams

**Permissions**
- Users with correct permissions can access features
- Users without permissions are blocked
- Role-based access control works correctly

**State Transitions**
- Resources progress through expected states
- State changes trigger appropriate UI updates
- Invalid state transitions are prevented

### What NOT to Test

**Implementation Details**
- Avoid: "Then the 'projects' table should have 2 rows"
- Good: "Then I should see the project 'Project Alpha'"

**CSS/Styling**
- Avoid: "Then the button should be blue"
- Good: "Then I should see a 'Create' button"

**Exact HTML Structure**
- Avoid: "Then the page should have a div with class 'container'"
- Good: "Then I should see the project details"

**Database Queries**
- Avoid: Testing SQL or ActiveRecord query methods
- Good: Testing that data appears correctly in the UI

## User Story Mapping

### Feature-Level Tags

```gherkin
@javascript @US-01
Feature: Manage Projects
```

Maps entire feature to `US-01: Project Management`

### Scenario-Level Tags

```gherkin
@US-01-AC-03
Scenario: Create new project
```

Maps scenario to `US-01-AC-03: Creating Projects`

### Multiple AC Tags

```gherkin
@US-06-AC-01 @US-06-AC-02 @US-06-AC-03
Scenario: Multiple users can join and see each other in real-time
```

Indicates scenario tests multiple acceptance criteria simultaneously

### Running Tagged Scenarios

```bash
# Run all scenarios for a user story
bundle exec cucumber --tags @US-01

# Run scenarios for a specific AC
bundle exec cucumber --tags @US-01-AC-03

# Run all multi-user scenarios
bundle exec cucumber --tags @multiuser

# Exclude JavaScript scenarios (for faster feedback)
bundle exec cucumber --tags "not @javascript"
```

## Background vs. Scenario Setup

### Background

Use for common setup shared across ALL scenarios in a feature:

```gherkin
Background:
  Given the following projects exist
    | id | title        | description     |
    |  1 | Web Redesign | Redesign main site |
```

- Runs before each scenario
- Reduces duplication
- Makes scenarios more readable

### Scenario-Specific Setup

Use Given steps within scenarios for unique setup:

```gherkin
Scenario: Create project without title
  Given I am logged in as a user "project-manager" with roles
    | role            |
    | projects:create |
  # ... scenario continues
```

## Rules for Organizing Scenarios

Use `Rule:` to group related scenarios:

```gherkin
Rule: Create projects

  @US-01-AC-03
  Scenario: Create new project
    # ...

  @US-01-AC-03
  Scenario: Create project without title
    # ...

Rule: Update projects

  @US-01-AC-04
  Scenario: Update project
    # ...
```

Benefits:
- Improves readability
- Mirrors acceptance criteria organization
- Groups related test cases

## Data Tables

### Horizontal Tables (Single Record)

```gherkin
When I fill in the project form with the following properties
  | Title       | My First Project |
  | Description | A sample project |
```

Use for:
- Form field values
- Single object attributes

### Vertical Tables (Multiple Records)

```gherkin
And the following projects exist
  | id | title         | description      |
  |  1 | Project Alpha | First project    |
  |  2 | Project Beta  | Second project   |
```

Use for:
- Creating multiple test records
- Defining collections

## Best Practices

### 1. Write Scenarios from User Perspective

**Good:**
```gherkin
When I create a new project with title "My Project"
Then I should see the project "My Project" in the list
```

**Avoid:**
```gherkin
When I POST to /projects with params {"title": "My Project"}
Then the database should have a project with title "My Project"
```

### 2. Keep Scenarios Focused

Each scenario should test one specific behavior:

**Good:**
```gherkin
Scenario: Create project without title
  When I create a project without a title
  Then I should see the error "Title can't be blank"
```

**Avoid:**
```gherkin
Scenario: Test all project validations
  # Tests 10 different validation scenarios
```

### 3. Use Meaningful Test Data

**Good:**
```gherkin
And the following projects exist
  | title                        | description     |
  | Software Development Project | Web application |
```

**Avoid:**
```gherkin
And the following projects exist
  | title  | description |
  | Test 1 | Desc 1      |
```

### 4. Reuse Common Steps

Use steps from `common_steps.rb` for shared patterns:
- Authentication
- Generic CRUD operations
- Status message assertions
- Navigation

Create resource-specific steps only when needed:
- Complex interactions unique to a resource
- Domain-specific assertions

### 5. Balance DRY and Readability

**Good (Readable):**
```gherkin
Given I am logged in as a user "alice" with roles
  | role                            |
  | estimation_sessions:participate |
When I visit the project "Web Redesign"
And I join the estimation session
```

**Avoid (Too DRY):**
```gherkin
Given a user session setup for "alice"
When navigation and join completed
```

### 6. Test Both Success and Failure Paths

For each feature, test:
- Happy path (successful operation)
- Validation errors (missing/invalid data)
- Permission errors (unauthorized access)
- Edge cases (boundary conditions)

### 7. Use Descriptive Scenario Names

Names should explain what is being tested without reading the steps:

**Good:**
- "Create project without title"
- "Delete effort node with children removes all descendants"
- "Facilitator selects parameters and participants see updates in real-time"

**Avoid:**
- "Test 1"
- "Validation"
- "Success case"

## Debugging Features

### View Browser During Test

Add `And I pause` step to halt execution:

```gherkin
When I visit the projects page
And I pause
Then I should see the project "Alpha"
```

This opens the browser for manual inspection.

### Save Screenshot

```ruby
# In step definition
save_screenshot('debug.png')
```

### Print Page Content

```ruby
# In step definition
puts page.html
```

### Check Capybara Session

```ruby
# In step definition
puts Capybara.current_session.inspect
puts Capybara.session_name
```

## Performance Considerations

### JavaScript Tests are Slow

JavaScript tests (`@javascript` tag) are significantly slower than non-JavaScript tests because they:
- Launch a real browser (Selenium)
- Wait for JavaScript to execute
- Wait for Turbo updates
- Render full UI

**Strategy:**
- Use `@javascript` only when necessary
- Test JavaScript-heavy features (Turbo, Stimulus) with Cucumber
- Test simple CRUD without JavaScript using request specs

### Multi-User Tests are Even Slower

Multi-user tests (`@multiuser` tag) require multiple browser sessions:
- Each user gets separate session
- Must coordinate between sessions
- Tests real-time broadcasts

**Strategy:**
- Use sparingly, only for real-time collaboration features
- Keep scenarios focused and minimal
- Consider testing real-time updates in a separate suite

## Integration with User Stories

Features directly implement user story acceptance criteria:

1. **User Story** defines acceptance criteria
2. **Feature file** maps to user story with `@US-XX` tag
3. **Scenarios** map to acceptance criteria with `@US-XX-AC-YY` tags
4. **Steps** implement the test for each scenario

This creates traceability:
```
User Story (docs/user_stories/project_management.md)
  ↓
Feature (features/project_management.feature) [@US-01]
  ↓
Scenario (Create new project) [@US-01-AC-03]
  ↓
Steps (Given/When/Then)
  ↓
Step Definitions (features/step_definitions/*.rb)
```

## Running Features

```bash
# Run all features
bundle exec cucumber

# Run specific feature file
bundle exec cucumber features/projects.feature

# Run specific scenario by line number
bundle exec cucumber features/projects.feature:46

# Run scenarios matching user story
bundle exec cucumber --tags @US-01

# Run scenarios for specific AC
bundle exec cucumber --tags @US-01-AC-03

# Run without JavaScript (faster)
bundle exec cucumber --tags "not @javascript"

# Run with detailed output
bundle exec cucumber --format pretty

# Run and generate HTML report
bundle exec cucumber --format html --out results.html
```

## Related Documentation

- [steps.md](steps.md) - Step definition patterns and implementation
- [testing.md](testing.md) - Overall testing strategy
- [User Stories](../user_stories/README.md) - Feature requirements and acceptance criteria
