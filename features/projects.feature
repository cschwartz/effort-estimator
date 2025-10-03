@javascript
Feature: Manage Projects
  As a user
  I want to manage projects
  So that I can estimate efforts for a project

  Scenario: View projects list
    Given I am logged in as a user "project-manager" with roles
      | role          |
      | projects:list |
    And the following projects exist
      | id | title         | description                 |
      |  1 | Project Alpha | First project in the system |
      |  2 | Project Beta  | Second project for testing  |
    When I visit the projects page
    Then I should see the project "Project Alpha"
    And I should see the project "Project Beta"

  Scenario: View empty projects list
    Given I am logged in as a user "project-manager" with roles
      | role            |
      | projects:list   |
      | projects:create |
    When I visit the projects page
    Then I should see no projects

  Scenario: View specific project
    Given I am logged in as a user "project-manager" with roles
      | role          |
      | projects:list |
      | projects:view |
    And the following projects exist
      | id | title         | description                |
      |  1 | Project Gamma | Third project with details |
    When I visit the projects page
    And I select the project "Project Gamma"
    Then I should see project details including the title "Project Gamma"
    And I should see project details including the description "Third project with details"

  Rule: Create projects

    Scenario: Create new project
      Given I am logged in as a user "project-manager" with roles
        | role            |
        | projects:list   |
        | projects:create |
        | projects:view   |
      When I visit the projects page
      And I choose to create a new project
      And I fill in the project form with the following properties
        | Title       | My First Project                      |
        | Description | A sample project for testing purposes |
      And I create the project
      Then I should see a status message "Project was successfully created"
      And I should see the project "My First Project"

    Scenario: Create project without title
      Given I am logged in as a user "project-manager" with roles
        | role            |
        | projects:list   |
        | projects:create |
        | projects:view   |
      When I visit the projects page
      And I choose to create a new project
      And I fill in the project form with the following properties
        | Title       |                           |
        | Description | A project without a title |
      And I create the project
      Then I should see the error message "Title can't be blank"

  Rule: Update projects

    Scenario: Update project
      Given I am logged in as a user "project-manager" with roles
        | role            |
        | projects:list   |
        | projects:update |
        | projects:view   |
      And the following projects exist
        | id | title          | description          |
        |  1 | Original Title | Original description |
      When I visit the projects page
      And I choose to edit the project "Original Title"
      And I fill in the project form with the following properties
        | Title       | Updated Project Title |
        | Description | Updated description   |
      And I update the project
      Then I should see a status message "Project was successfully updated"
      And I should see project details including the title "Updated Project Title"

    Scenario: Update project with empty title
      Given I am logged in as a user "project-manager" with roles
        | role            |
        | projects:list   |
        | projects:update |
        | projects:view   |
      And the following projects exist
        | id | title          | description          |
        |  1 | Original Title | Original description |
      When I visit the projects page
      And I choose to edit the project "Original Title"
      And I fill in the project form with the following properties
        | Title       |                     |
        | Description | Updated description |
      And I update the project
      Then I should see the error message "Title can't be blank"

  Rule: Delete projects

    Scenario: Delete project
      Given I am logged in as a user "project-manager" with roles
        | role            |
        | projects:delete |
        | projects:list   |
      And the following projects exist
        | id | title             | description     |
        |  1 | Project to Delete | Will be removed |
      When I visit the projects page
      And I choose to delete the project "Project to Delete"
      Then I should see a status message "Project was successfully deleted."
      And I should not see the project "Project to Delete"
