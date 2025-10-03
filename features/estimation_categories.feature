@javascript
Feature: Manage Estimation Categories
  As a project manager
  I want to manage estimation categories for my project
  So that I can define the components for effort estimation

  Rule: View estimation categories

    Scenario: View all estimation categories
      Given I am logged in as a user "project-manager" with roles
        | role            |
        | projects:list   |
        | projects:show   |
        | categories:list |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following estimation categories exist
        | id | title          | category_type | project_id |
        |  1 | Conception     | scaled        |          1 |
        |  2 | Implementation | scaled        |          1 |
        |  3 | Hours          | absolute      |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      Then I should see the category "Conception" with type "Scaled"
      And I should see the category "Implementation" with type "Scaled"
      And I should see the category "Hours" with type "Absolute"

    Scenario: View empty categories list
      Given I am logged in as a user "project-manager" with roles
        | role            |
        | projects:list   |
        | projects:show   |
        | categories:list |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      Then I should see the message "No existing categories"

  Rule: Create estimation categories

    Scenario: Create new scaled estimation category
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | categories:list   |
        | categories:create |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      And I choose to create a new category
      And I fill in the category form with the following properties
        | Title           | Type   |
        | Scaled Category | Scaled |
      And I create the category
      Then I should see a status message "Category was successfully created"
      And I should see the category "Scaled Category" with type "Scaled"

    Scenario: Create new absolute estimation category
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | categories:list   |
        | categories:create |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      And I choose to create a new category
      And I fill in the category form with the following properties
        | Title             | Type     |
        | Absolute Category | Absolute |
      And I create the category
      Then I should see a status message "Category was successfully created"
      And I should see the category "Absolute Category" with type "Absolute"

    Scenario: Create category without title
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | categories:list   |
        | categories:create |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      And I choose to create a new category
      And I fill in the category form with the following properties
        | Title | Type   |
        |       | Scaled |
      And I create the category
      Then I should see the error message "Title can't be blank"

    Scenario: Create duplicate category title
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | categories:list   |
        | categories:create |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following estimation categories exist
        | id | title      | category_type | project_id |
        |  1 | Conception | scaled        |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      And I choose to create a new category
      And I fill in the category form with the following properties
        | Title      | Type     |
        | Conception | Absolute |
      And I create the category
      Then I should see the error message "Title has already been taken"

  Rule: Update estimation categories

    Scenario: Update estimation category title and type
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | categories:list   |
        | categories:update |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following estimation categories exist
        | id | title      | category_type | project_id |
        |  1 | Conception | scaled        |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      And I choose to edit the category "Conception"
      And I fill in the category form with the following properties
        | Title             | Type     |
        | Design & Planning | Absolute |
      And I update the category
      Then I should see a status message "Category was successfully updated"
      And I should see the category "Design & Planning" with type "Absolute"
      And I should not see the category "Conception"

    Scenario: Update category with empty title
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | categories:list   |
        | categories:update |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following estimation categories exist
        | id | title      | category_type | project_id |
        |  1 | Conception | scaled        |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      And I choose to edit the category "Conception"
      And I fill in the category form with the following properties
        | Title | Type   |
        |       | Scaled |
      And I update the category
      Then I should see the error message "Title can't be blank"

    Scenario: Update category with duplicate title
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | categories:list   |
        | categories:update |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following estimation categories exist
        | id | title          | category_type | project_id |
        |  1 | Conception     | scaled        |          1 |
        |  2 | Implementation | scaled        |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      And I choose to edit the category "Implementation"
      And I fill in the category form with the following properties
        | Title      | Type     |
        | Conception | Absolute |
      And I update the category
      Then I should see the error message "Title has already been taken"

  Rule: Delete estimation categories

    Scenario: Delete unused estimation category
      Given I am logged in as a user "project-manager" with roles
        | role              |
        | projects:list     |
        | projects:show     |
        | categories:list   |
        | categories:delete |
      And the following projects exist
        | id | title                        | description     |
        |  1 | Software Development Project | Web application |
      And the following estimation categories exist
        | id | title          | category_type | project_id |
        |  1 | Conception     | scaled        |          1 |
        |  2 | Implementation | scaled        |          1 |
      When I visit the projects page
      And I select the project "Software Development Project"
      And I visit the "Categories" section
      And I choose to delete the category "Implementation"
      Then I should see a status message "Category was successfully deleted"
      And I should see the category "Conception" with type "Scaled"
      And I should not see the category "Implementation"
