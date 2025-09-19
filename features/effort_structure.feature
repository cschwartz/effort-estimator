Feature: Manage Effort Tree Structure
  As a user
  I want to manage effort breakdown structures
  So that I can organize and track project work hierarchically

  Scenario: View root effort nodes
    Given I am logged in as a user "project-manager" with roles
      | role         |
      | efforts:list |
    And the following projects exist
      | id | title                        | description     |
      |  1 | Software Development Project | Web application |
    And the following effort nodes exist
      | id | title                | description   | parent_id | project_id |
      |  1 | Frontend Development | UI components |           |          1 |
      |  2 | Backend Development  | API services  |           |          1 |
      |  3 | User Authentication  | Login system  |         2 |          1 |
    When I visit the projects page
    And I select the project "Software Development Project"
    And I visit the "Effort Breakdown" section
    Then I should see the root effort "Frontend Development"
    And I should see the root effort "Backend Development"

  Scenario: View child effort nodes
    Given I am logged in as a user "project-manager" with roles
      | role         |
      | efforts:list |
    And the following projects exist
      | id | title                        | description     |
      |  1 | Software Development Project | Web application |
    And the following effort nodes exist
      | id | title                | description   | parent_id | project_id |
      |  1 | Frontend Development | UI components |           |          1 |
      |  2 | Backend Development  | API services  |           |          1 |
      |  3 | User Authentication  | Login system  |         2 |          1 |
    When I visit the projects page
    And I select the project "Software Development Project"
    And I visit the "Effort Breakdown" section
    And I expand the effort "Backend Development"
    Then I should see the effort "User Authentication" at path "Backend Development"

  Rule: Create effort nodes

    Scenario: Create root effort node
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:list   |
        | efforts:create |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Effort Breakdown" section
      And I choose to create a new root effort
      And I fill in the effort form with the following properties
        | Title       | Database Design |
        | Description | Database schema |
      And I submit the form
      Then I should see a status message "Effort was successfully created"
      And I should see the root effort "Database Design"

    Scenario: Create child effort node
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:list   |
        | efforts:create |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following effort nodes exist
        | id | title               | description  | parent_id | project_id |
        |  1 | Backend Development | API services |           |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Effort Breakdown" section
      And I expand the effort "Backend Development"
      And I choose to create a new child effort under "Backend Development"
      And I fill in the effort form with the following properties
        | Title       | Database Integration |
        | Description | DB connection layer  |
      And I submit the form
      Then I should see a status message "Effort was successfully created"
      And I should see the effort "Database Integration" at path "Backend Development"

    Scenario: Create effort node without a title
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:list   |
        | efforts:create |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Effort Breakdown" section
      And I choose to create a new root effort
      And I fill in the effort form with the following properties
        | Title       |                  |
        | Description | Some description |
      And I submit the form
      Then I should see the error message "Title can't be blank"

    Scenario: Create child effort node without a title
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:list   |
        | efforts:create |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following effort nodes exist
        | id | title               | description  | parent_id | project_id |
        |  1 | Backend Development | API services |           |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Effort Breakdown" section
      And I expand the effort "Backend Development"
      And I choose to create a new child effort under "Backend Development"
      And I fill in the effort form with the following properties
        | Title       |                  |
        | Description | Some description |
      And I submit the form
      Then I should see the error message "Title can't be blank"

  Rule: Update effort nodes

    Scenario: Update effort node
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:update |
        | efforts:list   |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following effort nodes exist
        | id | title               | description  | parent_id | project_id |
        |  1 | Backend Development | API services |           |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Effort Breakdown" section
      And I choose to edit the effort "Backend Development"
      And I fill in the effort form with the following properties
        | Title       | Updated Backend Development |
        | Description | Updated API services        |
      And I submit the form
      Then I should see a status message "Effort was successfully updated"
      And I should see the root effort "Updated Backend Development"

    Scenario: Update effort node with empty title
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:update |
        | efforts:list   |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following effort nodes exist
        | id | title               | description  | parent_id | project_id |
        |  1 | Backend Development | API services |           |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Effort Breakdown" section
      And I choose to edit the effort "Backend Development"
      And I fill in the effort form with the following properties
        | Title       |                     |
        | Description | Updated description |
      And I submit the form
      Then I should see the error message "Title can't be blank"

  Rule: Delete effort nodes

    Scenario: Delete root effort node
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:delete |
        | efforts:list   |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following effort nodes exist
        | id | title               | description  | parent_id | project_id |
        |  1 | Backend Development | API services |           |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Effort Breakdown" section
      And I choose to delete the effort "Backend Development"
      Then I should see a status message "Effort was successfully deleted"
      And I should not see the root effort "Backend Development"

    Scenario: Delete child effort node
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:delete |
        | efforts:list   |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following effort nodes exist
        | id | title               | description  | parent_id | project_id |
        |  1 | Backend Development | API services |           |          1 |
        |  2 | User Authentication | Login system |         1 |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Effort Breakdown" section
      And I expand the effort "Backend Development"
      And I choose to delete the effort "User Authentication" under "Backend Development"
      Then I should see a status message "Effort was successfully deleted"
      And I should not see the effort "User Authentication" at path "Backend Development"

    Scenario: Delete effort node with children removes all descendants
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:delete |
        | efforts:list   |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following effort nodes exist
        | id | title               | description  | parent_id | project_id |
        |  1 | Backend Development | API services |           |          1 |
        |  2 | User Authentication | Login system |         1 |          1 |
        |  3 | Login Form          | UI component |         2 |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Effort Breakdown" section
      And I choose to delete the effort "Backend Development"
      Then I should see a status message "Effort was successfully deleted"
      And I should not see the root effort "Backend Development"

  Rule: Move effort nodes

    Scenario: Reorder effort nodes among siblings
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:update |
        | efforts:list   |
      And I am working on project "Software Development Project"
      And the following effort nodes exist in order
        | id | title                | description   | parent_id | position |
        |  1 | Frontend Development | UI components |           |        1 |
        |  2 | Backend Development  | API services  |           |        2 |
        |  3 | Testing Phase        | QA testing    |           |        3 |
      When I enter the "Effort Breakdown" section
      And I move "Backend Development" to position 1 among its siblings
      Then I should see the root entries
        | title                |
        | Backend Development  |
        | Frontend Development |
        | Testing Phase        |

    Scenario: Move effort node to different parent
      Given I am logged in as a user "project-manager" with roles
        | role           |
        | efforts:update |
        | efforts:list   |
      And I am working on project "Software Development Project"
      And the following effort nodes exist
        | id | title                | description   | parent_id |
        |  1 | Frontend Development | UI components |           |
        |  2 | Backend Development  | API services  |           |
        |  3 | User Authentication  | Login system  |         2 |
        |  4 | Login Form           | UI component  |         3 |
      When I enter the "Effort Breakdown" section
      And I move "Login Form" to be a child of "Frontend Development"
      And I expand the "Frontend Development" entry
      Then I should see the following below the path "Frontend Development >"
        | title      | parent_title         |
        | Login Form | Frontend Development |
      And I should not see "Login Form" below the path "Backend Development > User Authentication >"
