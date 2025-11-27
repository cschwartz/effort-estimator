@javascript @multiuser @US-06
Feature: Estimation Session
  As a project member
  I want to collaboratively estimate effort for leaf nodes in real-time
  So that the team can reach consensus on effort estimates through structured voting

  Background:
    Given the following projects exist
      | id | title        | description        |
      |  1 | Web Redesign | Redesign main site |
    And the following estimation options exist with values
      | title     | values    |
      | Fibonacci | 1,2,3,5,8 |
    And the following estimation categories exist
      | id | title          | category_type | project_id |
      |  1 | Implementation | scaled        |          1 |
      |  2 | Complexity     | absolute      |          1 |
    And the following estimation parameters exist
      | id | title              | project_id |
      |  1 | Number of Features |          1 |
      |  2 | Number of Pages    |          1 |
    And the following effort nodes exist
      | id | title        | description | parent_id | project_id |
      |  1 | Frontend     | UI work     |           |          1 |
      |  2 | Login Page   | Login UI    |         1 |          1 |
      |  3 | Profile Page | Profile UI  |         1 |          1 |

  @US-06-AC-01
  Scenario: Starting an estimation session
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    When I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    Then I should be on the estimation session page
    And I should see "Login Page" as the current effort
    And I should see the category "Implementation" is active
    And I should see "alice@example.com" in the participants list
    And I should see "Facilitator" next to "alice@example.com"

  @US-06-AC-02
  Scenario: Joining an estimation session
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I am logged in as a user "bob" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
    When I am acting as the user "alice"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I am acting as the user "bob"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I choose to join the estimation session
    Then I should be on the estimation session page
    And I should see "Login Page" as the current effort
    And I should see "alice@example.com" in the participants list
    And I should see "bob@example.com" in the participants list

  @US-06-AC-02 @US-06-AC-03
  Scenario: Multiple users can join and see each other in real-time
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I am logged in as a user "bob" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
    When I am acting as the user "alice"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I am acting as the user "bob"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I join the estimation session
    And I am acting as the user "alice"
    Then I should see "alice@example.com" in the participants list
    And I should see "Facilitator" next to "alice@example.com"
    And I should see "bob@example.com" in the participants list
    And I am acting as the user "bob"
    Then I should see "alice@example.com" in the participants list
    And I should see "bob@example.com" in the participants list

  @US-06-AC-04 @wip
  Scenario: Viewing current effort node and category
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    When I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    Then I should see "Login Page" as the current effort
    And I should see "Login UI" in the effort description
    And I should see the category "Implementation" is active
    And I should see the category "Complexity" is pending

  @US-06-AC-05 @wip
  Scenario: Estimating a scaled category with parameter selection
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I am logged in as a user "bob" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
    When I am acting as the user "alice"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I am acting as the user "bob"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I join the estimation session
    And I am acting as the user "alice"
    And I select parameter "Number of Features" for category "Implementation"
    And I am acting as the user "bob"
    And I should see parameter "Number of Features" selected for category "Implementation"
    And I should see voting is now active
    And I cast my vote for "5"
    And I should see that I have voted
    And I am acting as the user "alice"
    And I cast my vote for "8"
    And I should see voting progress "2/2 voted"
    And I reveal the votes
    And I should see the vote results by participant
      | Participant       | Vote |
      | alice@example.com |    8 |
      | bob@example.com   |    5 |
    And I am acting as the user "bob"
    And I should see the vote results by participant
      | Participant       | Vote |
      | alice@example.com |    8 |
      | bob@example.com   |    5 |
    And I should not see the finalize button
    And I am acting as the user "alice"
    And I finalize the estimate with value "5"
    And I should see the category "Implementation" is finalized with value "5"
    And I proceed to the next estimation
    Then I should see the category "Complexity" is active

  @US-06-AC-06 @wip
  Scenario: Estimating an absolute category
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I am logged in as a user "bob" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
    And I am acting as the user "alice"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I select parameter "Number of Features" for category "Implementation"
    And I am acting as the user "bob"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I join the estimation session
    And I am acting as the user "alice"
    And I cast my vote for "5"
    And I am acting as the user "bob"
    And I cast my vote for "5"
    And I am acting as the user "alice"
    And I reveal the votes
    And I finalize the estimate with value "5"
    When I activate the next category
    And I should see the category "Complexity" is active
    And I should see voting is now active
    And I should not see parameter selection for category "Complexity"
    And I cast my vote for "2"
    And I am acting as the user "bob"
    And I cast my vote for "9"
    And I should see voting progress "2/2 voted"
    And I am acting as the user "alice"
    And I reveal the votes
    And I should see the vote results by participant
      | Participant       | Vote |
      | alice@example.com |    2 |
      | bob@example.com   |    3 |
    And I am acting as the user "bob"
    And I should see the vote results by participant
      | Participant       | Vote |
      | alice@example.com |    2 |
      | bob@example.com   |    9 |
    And I should not see the finalize button
    And I am acting as the user "alice"
    And I finalize the estimate with value "3"
    And I proceed to the next estimation
    Then I should see the effort "Profile Page" is active

  @US-06-AC-05 @wip
  Scenario: Facilitator can select compromise value with zero votes
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I am logged in as a user "bob" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
    And I am acting as the user "alice"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I select parameter "Number of Features" for category "Implementation"
    And I cast my vote for "3"
    And I am acting as the user "bob"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I join the estimation session
    And I cast my vote for "8"
    When I am acting as the user "alice"
    And I reveal the votes
    And I finalize the estimate with value "5"
    Then I should see the category "Implementation" is finalized with value "5"

  @US-06-AC-05 @wip
  Scenario: Participant can change their vote before reveal
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I am logged in as a user "bob" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
    And I am acting as the user "alice"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I select parameter "Number of Features" for category "Implementation"
    And I am acting as the user "bob"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I join the estimation session
    When I cast my vote for "3"
    Then I should see that I have voted
    And I should see voting progress "1/2 voted"
    When I cast my vote for "8"
    Then I should see that I have voted
    And I should see voting progress "1/2 voted"
    When I am acting as the user "alice"
    And I cast my vote for "8"
    And I reveal the votes
    Then I should see the vote results by participant
      | Participant       | Vote |
      | alice@example.com |    8 |
      | bob@example.com   |    8 |

  @US-06-AC-07 @wip
  Scenario: Facilitator navigates between effort nodes
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I am logged in as a user "bob" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
    And I am acting as the user "alice"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I complete estimation for the current effort with
      | Category       | Parameter          | Value |
      | Implementation | Number of Features |     5 |
      | Complexity     |                    |     3 |
    When I am acting as the user "alice"
    And I navigate to effort "Login Page"
    Then I should see "Login Page" as the current effort
    And I should see the category "Implementation" is finalized with value "5"
    And I am acting as the user "bob"
    And I should see "Login Page" as the current effort

  @US-06-AC-07 @wip
  Scenario: Facilitator skips effort node and returns later
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    When I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I should see "Login Page" as the current effort
    And I skip the current effort
    Then I should see "Profile Page" as the current effort

  @US-06-AC-08 @wip
  Scenario: Re-estimating a previously estimated effort node
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I complete estimation for the current effort with
      | Category       | Parameter          | Value |
      | Implementation | Number of Features |     5 |
      | Complexity     |                    |     3 |
    When I navigate to effort "Login Page"
    And I restart estimation for category "Implementation"
    Then I should see parameter "Number of Features" is pre-selected
    And I should see voting is now active

  @US-06-AC-09 @wip
  Scenario: Viewing estimation progress as facilitator
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    When I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    Then I should see the effort tree with progress
    And I should see "Login Page" is marked as "in progress"
    And I should see "Profile Page" is marked as "not estimated"

  @US-06-AC-10 @wip
  Scenario: Participant leaves estimation session
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I am logged in as a user "bob" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
    And I am acting as the user "alice"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I am acting as the user "bob"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I join the estimation session
    When I leave the estimation session
    Then I should be on the project page
    When I am acting as the user "alice"
    Then I should not see "bob@example.com" in the participants list

  @US-06-AC-10 @wip
  Scenario: Participant rejoins after leaving
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I am logged in as a user "bob" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
    And I am acting as the user "alice"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I select parameter "Number of Features" for category "Implementation"
    And I am acting as the user "bob"
    And I visit the projects page
    And I select the project "Web Redesign"
    And I join the estimation session
    And I cast my vote for "5"
    When I leave the estimation session
    And I select the project "Web Redesign"
    And I join the estimation session
    Then I should see "Login Page" as the current effort
    And I should see that I have voted

  @US-06-AC-11 @wip
  Scenario: Facilitator completes estimation session
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    And I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I complete estimation for the current effort with
      | Category       | Parameter          | Value |
      | Implementation | Number of Features |     5 |
      | Complexity     |                    |     3 |
    And I complete estimation for the current effort with
      | Category       | Parameter          | Value |
      | Implementation | Number of Features |     8 |
      | Complexity     |                    |     5 |
    And I complete the estimation session
    Then I should see "Estimation session completed"
    And the session status should be "completed"

  @US-06-AC-11 @wip
  Scenario: Facilitator completes session with incomplete estimates
    Given I am logged in as a user "alice" with roles
      | role                            |
      | projects:list                   |
      | projects:view                   |
      | estimation_sessions:participate |
      | estimation_sessions:facilitate  |
    When I visit the projects page
    And I select the project "Web Redesign"
    And I start the estimation with "Fibonacci" as the estimation option
    And I complete estimation for the current effort with
      | Category       | Parameter          | Value |
      | Implementation | Number of Features |     5 |
      | Complexity     |                    |     3 |
    When I complete the estimation session
    Then I should see a warning "Not all leaves have been estimated"
    When I confirm the completion
    Then I should see "Estimation session completed"
    And the session status should be "completed"
