---
id: US-04
feature: Estimation Options
epic: Core Platform
priority: High
status: Implemented
test_coverage: features/estimation_options.feature
related_features:
  - Estimation Categories
---

# User Story: Estimation Options

## User Story

**As a** system administrator
**I want to** manage estimation options
**So that** I can define predefined value sets for planning poker

## Acceptance Criteria

### US-04-AC-01: Listing Estimation Options

- In the estimation options list, users with `estimation_options:list` permission can view a list of all estimation options
- Each estimation option displays its title
- When no estimation options exist, the system shows no estimation options

### US-04-AC-02: Viewing Estimation Option Details

- In the estimation options list, users with `estimation_options:list` permission can select an estimation option to view its detailed information
- Estimation option details display the title and all associated values

### US-04-AC-03: Creating Estimation Options

**Prerequisites**: User must have `estimation_options:create` and `estimation_options:list` permissions

- In the estimation options list, users can initiate estimation option creation
- Estimation option creation form includes:
  - Title field (must be unique system-wide)
- Valid estimation option submission:
  - Creates the estimation option in the system
  - Shows success message: "Estimation option was successfully created."
  - Displays the new estimation option in the list
- Invalid estimation option submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not create the estimation option

### US-04-AC-04: Updating Estimation Options

**Prerequisites**: User must have `estimation_options:update` and `estimation_options:list` permissions

- In the estimation options list, users can edit existing estimation options
- Update form pre-fills with current estimation option data
- Form includes same fields as creation (title must remain unique system-wide)
- Valid update submission:
  - Updates the estimation option in the system
  - Shows success message: "Estimation option was successfully updated."
  - Displays updated information in the list
- Invalid update submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not save the changes

### US-04-AC-05: Deleting Estimation Options

**Prerequisites**: User must have `estimation_options:delete` and `estimation_options:list` permissions

- In the estimation options list, users can delete existing estimation options
- Successful deletion:
  - Removes the estimation option from the system
  - Shows success message: "Estimation option was successfully deleted."
  - Removes the estimation option from the list

### US-04-AC-06: Managing Estimation Option Values

**Prerequisites**: User must have `estimation_options:update` permission

- In the estimation option details, users can add values to the estimation option
- In the estimation option details, users can remove values from the estimation option
- Valid value addition:
  - Adds the value to the estimation option
  - Shows success message: "Estimation option was successfully updated."
  - Displays the new value in the values list
- Invalid value addition:
  - Shows appropriate validation error messages
  - Does not add the value
- Valid value removal:
  - Removes the value from the estimation option
  - Shows success message: "Estimation option was successfully updated."
  - Removes the value from the values list

## Validation Rules

| Field | Required | Constraints |
|-------|----------|-------------|
| Title | Yes | Cannot be blank; must be unique system-wide |
| Values | No | Each value must be greater than 0; values must be unique within the estimation option |

## Permission Requirements

| AC ID | Acceptance Criteria | Required Permissions |
|-------|---------------------|---------------------|
| US-04-AC-01 | Listing Estimation Options | `estimation_options:list` |
| US-04-AC-02 | Viewing Estimation Option Details | `estimation_options:list` |
| US-04-AC-03 | Creating Estimation Options | `estimation_options:list`, `estimation_options:create` |
| US-04-AC-04 | Updating Estimation Options | `estimation_options:list`, `estimation_options:update` |
| US-04-AC-05 | Deleting Estimation Options | `estimation_options:list`, `estimation_options:delete` |
| US-04-AC-06 | Managing Estimation Option Values | `estimation_options:update` |

## User Experience Flow

### Happy Path: Creating an Estimation Option with Values

1. User navigates to estimation options page
2. User clicks "Create" action
3. System displays estimation option creation form in a modal/frame
4. User enters a unique title (system-wide)
5. User submits the form
6. System validates input (including uniqueness of title system-wide)
7. System creates the estimation option
8. System shows success message
9. System displays the new estimation option in the list
10. User can view the estimation option details
11. User adds values to the estimation option (e.g., 1, 2, 3, 5, 8)

### Alternative Path: Validation Error

1. User attempts to create or update an estimation option with invalid data (e.g., missing required title, duplicate title)
2. System validates the form
3. System displays validation error messages inline in the form
4. User corrects the errors
5. User resubmits the form
6. System processes the valid submission

### Alternative Path: Adding Invalid Value

1. User attempts to add an invalid value (e.g., 0, negative number, or duplicate value)
2. System validates the value
3. System displays validation error message
4. User corrects the value
5. User resubmits
6. System adds the valid value

## Estimation Option Purpose

Estimation options represent predefined value sets used in planning poker and other estimation techniques. Common examples include:
- **Fibonacci < 40**: 1, 2, 3, 5, 8, 13, 21, 34
- **Small Integers**: 1, 2, 3, 4, 5

These options provide consistent scales that teams can use across multiple projects for scaled estimation categories.