@javascript @US-03
Feature: Manage Estimation Parameters
  As a project manager
  I want to manage estimation parameters for my project
  So that I can define variables for relative estimations

  Background:
    Given the following projects exist
      | id | title                        | description     |
      |  1 | Software Development Project | Web application |

  Rule: View estimation parameters

    @US-03-AC-01
    Scenario: View all estimation parameters
      Given I am logged in as a user "project-manager" with roles
        | role            |
        | projects:list   |
        | projects:show   |
        | parameters:list |
      And the following estimation parameters exist
        | id | title              | project_id |
        |  1 | Number of Features |          1 |
        |  2 | Team Size          |          1 |
        |  3 | Complexity Factor  |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Parameters" section
      Then I should see the parameter "Number of Features"
      And I should see the parameter "Team Size"
      And I should see the parameter "Complexity Factor"

    @US-03-AC-01
    Scenario: View empty parameters list
      Given I am logged in as a user "project-manager" with roles
        | role            |
        | projects:list   |
        | projects:show   |
        | parameters:list |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Parameters" section
      Then I should see the message "No existing Parameters"

  Rule: Create estimation parameters

    @US-03-AC-02
    Scenario: Create new estimation parameter
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | parameters:list   |
        | parameters:create |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Parameters" section
      And I choose to create a new parameter
      And I fill in the parameter form with the following properties
        | Title              |
        | Number of Features |
      And I create the parameter
      Then I should see a status message "Parameter was successfully created"
      And I should see the parameter "Number of Features"

    @US-03-AC-02
    Scenario: Create parameter without title
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | parameters:list   |
        | parameters:create |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Parameters" section
      And I choose to create a new parameter
      And I fill in the parameter form with the following properties
        | Title |
        |       |
      And I create the parameter
      Then I should see the error message "Title can't be blank"

    @US-03-AC-02
    Scenario: Create duplicate parameter title
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | parameters:list   |
        | parameters:create |
      And the following estimation parameters exist
        | id | title     | project_id |
        |  1 | Team Size |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Parameters" section
      And I choose to create a new parameter
      And I fill in the parameter form with the following properties
        | Title     |
        | Team Size |
      And I create the parameter
      Then I should see the error message "Title has already been taken"

  Rule: Update estimation parameters

    @US-03-AC-03
    Scenario: Update estimation parameter title
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | parameters:list   |
        | parameters:update |
      And the following estimation parameters exist
        | id | title     | project_id |
        |  1 | Team Size |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Parameters" section
      And I choose to edit the parameter "Team Size"
      And I fill in the parameter form with the following properties
        | Title                |
        | Number of Developers |
      And I update the parameter
      Then I should see a status message "Parameter was successfully updated"
      And I should see the parameter "Number of Developers"
      And I should not see the parameter "Team Size"

    @US-03-AC-03
    Scenario: Update parameter with empty title
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | parameters:list   |
        | parameters:update |
      And the following estimation parameters exist
        | id | title     | project_id |
        |  1 | Team Size |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Parameters" section
      And I choose to edit the parameter "Team Size"
      And I fill in the parameter form with the following properties
        | Title |
        |       |
      And I update the parameter
      Then I should see the error message "Title can't be blank"

    @US-03-AC-03
    Scenario: Update parameter with duplicate title
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | parameters:list   |
        | parameters:update |
      And the following estimation parameters exist
        | id | title             | project_id |
        |  1 | Team Size         |          1 |
        |  2 | Complexity Factor |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Parameters" section
      And I choose to edit the parameter "Team Size"
      And I fill in the parameter form with the following properties
        | Title             |
        | Complexity Factor |
      And I update the parameter
      Then I should see the error message "Title has already been taken"

  Rule: Delete estimation parameters

    @US-03-AC-04
    Scenario: Delete unused estimation parameter
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | parameters:list   |
        | parameters:delete |
      And the following estimation parameters exist
        | id | title             | project_id |
        |  1 | Team Size         |          1 |
        |  2 | Complexity Factor |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Parameters" section
      And I choose to delete the parameter "Complexity Factor"
      Then I should see a status message "Parameter was successfully deleted"
      And I should see the parameter "Team Size"
      And I should not see the parameter "Complexity Factor"
