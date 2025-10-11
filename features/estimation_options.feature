@javascript
Feature: Manage Estimation Options
  As a system administrator
  I want to manage estimation options
  So that I can define predefined value sets for planning poker

  Background:
    Given I am logged in as a user "admin" with roles
      | role                      |
      | estimation_options:list   |
      | estimation_options:create |
      | estimation_options:update |
      | estimation_options:delete |

  Scenario: View all estimation options
    Given the following estimation options exist with values
      | title          | values             |
      | Fibonacci < 40 | 1,2,3,5,8,13,21,34 |
      | Small Integers |       1,2,3,5,8,13 |
    When I visit the estimation options page
    Then I should see the estimation option "Fibonacci < 40"
    And I should see the estimation option "Small Integers"

  Scenario: View empty estimation options list
    When I visit the estimation options page
    Then I should see no estimation options

  Scenario: View estimation option details
    Given the following estimation option exists with values
      | title          | values                    |
      | Fibonacci < 40 | 1, 2, 3, 5, 8, 13, 21, 34 |
    When I visit the estimation options page
    And I select the estimation option "Fibonacci < 40"
    Then I should see estimation option details including the name "Fibonacci < 40"
    And I should see the values "1, 2, 3, 5, 8, 13, 21, 34" for the estimation option

  Scenario: Create new estimation option
    When I visit the estimation options page
    And I choose to create a new estimation option
    And I fill in the estimation option form with the following properties
      | Title | Fibonacci < 40 |
    And I create the estimation option
    Then I should see a status message "Estimation option was successfully created."
    And I should see the estimation option "Fibonacci < 40"

  Scenario: Create estimation option without name
    When I visit the estimation options page
    And I choose to create a new estimation option
    And I fill in the estimation option form with the following properties
      | Title |  |
    And I create the estimation option
    Then I should see the error message "Title can't be blank"

  Scenario: Create duplicate estimation option name
    Given the following estimation options exist
      | title          |
      | Fibonacci < 40 |
    When I visit the estimation options page
    And I choose to create a new estimation option
    And I fill in the estimation option form with the following properties
      | Title | Fibonacci < 40 |
    And I create the estimation option
    Then I should see the error message "Title has already been taken"

  Scenario: Update estimation option name
    Given the following estimation options exist
      | title         |
      | Small Numbers |
    When I visit the estimation options page
    And I choose to edit the estimation option "Small Numbers"
    And I fill in the estimation option form with the following properties
      | Title | Small Integers |
    And I update the estimation option
    Then I should see a status message "Estimation option was successfully updated."
    And I should see the estimation option "Small Integers"
    And I should not see the estimation option "Small Numbers"

  Scenario: Update estimation option with empty name
    Given the following estimation options exist
      | title         |
      | Small Numbers |
    When I visit the estimation options page
    And I choose to edit the estimation option "Small Numbers"
    And I fill in the estimation option form with the following properties
      | Title |  |
    And I update the estimation option
    Then I should see the error message "Title can't be blank"

  Scenario: Update estimation option with duplicate name
    Given the following estimation options exist
      | title          |
      | Fibonacci < 40 |
      | Small Numbers  |
    When I visit the estimation options page
    And I choose to edit the estimation option "Small Numbers"
    And I fill in the estimation option form with the following properties
      | Title | Fibonacci < 40 |
    And I update the estimation option
    Then I should see the error message "Title has already been taken"

  Scenario: Delete unused estimation option
    Given the following estimation options exist with values
      | title         | values |
      | Small Numbers |  1,2,3 |
    When I visit the estimation options page
    And I choose to delete the estimation option "Small Numbers"
    Then I should see a status message "Estimation option was successfully deleted."
    And I should not see the estimation option "Small Numbers"

  Scenario: Add value to estimation option
    Given the following estimation options exist with values
      | title          | values    |
      | Fibonacci < 40 | 1,2,3,5,8 |
    When I visit the estimation option "Fibonacci < 40" page
    And I add the value "13" to the estimation option
    Then I should see a status message "Estimation option was successfully updated."
    And I should see the value "13" in the estimation option

  Scenario: Add non-positive value to estimation option
    Given the following estimation options exist with values
      | title          | values  |
      | Fibonacci < 40 | 1,2,3,5 |
    When I visit the estimation option "Fibonacci < 40" page
    And I add the value "0" to the estimation option
    Then I should see the error message "Estimation option values value must be greater than 0"

  Scenario: Add duplicate value to estimation option
    Given the following estimation options exist with values
      | title          | values  |
      | Fibonacci < 40 | 1,2,3,5 |
    When I visit the estimation option "Fibonacci < 40" page
    And I add the value "5" to the estimation option
    Then I should see the error message "Estimation option values value has already been taken"

  Scenario: Remove value from estimation option
    Given the following estimation options exist with values
      | title          | values    |
      | Fibonacci < 40 | 1,2,3,5,8 |
    When I visit the estimation option "Fibonacci < 40" page
    And I remove the value "8" from the estimation option
    Then I should see a status message "Estimation option was successfully updated."
    And I should not see the value "8" in the estimation option
    And I should see the value "5" in the estimation option
