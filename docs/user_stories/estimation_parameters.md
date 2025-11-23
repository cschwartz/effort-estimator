---
id: US-03
feature: Estimation Parameters
epic: Core Platform
priority: High
status: Implemented
test_coverage: features/estimation_parameters.feature
related_features:
  - Project Management
  - Parameter Selection
---

# User Story: Estimation Parameters

## User Story

**As a** project manager
**I want to** manage estimation parameters for my project
**So that** I can define variables for relative estimation dimensions

## Acceptance Criteria

### US-03-AC-01: Listing Estimation Parameters

- In the project's Parameters section, users with `parameters:list` permission can view a list of all estimation parameters
- Each parameter displays its title
- When no parameters exist, the system shows "No existing Parameters" message

### US-03-AC-02: Creating Estimation Parameters

**Prerequisites**: User must have `parameters:create`, `parameters:list`, `projects:show`, and `projects:list` permissions

- In the project's Parameters section, users can initiate parameter creation
- Parameter creation form includes:
  - Title field (must be unique within the project)
- Valid parameter submission:
  - Creates the parameter in the system
  - Shows success message: "Parameter was successfully created"
  - Displays the new parameter in the parameters list
- Invalid parameter submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not create the parameter

### US-03-AC-03: Updating Estimation Parameters

**Prerequisites**: User must have `parameters:update`, `parameters:list`, `projects:show`, and `projects:list` permissions

- In the project's Parameters section, users can edit existing parameters
- Update form pre-fills with current parameter data
- Form includes same fields as creation (title must remain unique within the project)
- Valid update submission:
  - Updates the parameter in the system
  - Shows success message: "Parameter was successfully updated"
  - Displays updated information in the parameters list
- Invalid update submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not save the changes

### US-03-AC-04: Deleting Estimation Parameters

**Prerequisites**: User must have `parameters:delete`, `parameters:list`, `projects:show`, and `projects:list` permissions

- In the project's Parameters section, users can delete existing parameters
- Successful deletion:
  - Removes the parameter from the system
  - Shows success message: "Parameter was successfully deleted"
  - Removes the parameter from the parameters list

## Validation Rules

| Field | Required | Constraints |
|-------|----------|-------------|
| Title | Yes | Cannot be blank; must be unique within project |

## Permission Requirements

| AC ID | Acceptance Criteria | Required Permissions |
|-------|---------------------|---------------------|
| US-03-AC-01 | Listing Estimation Parameters | `parameters:list`, `projects:show`, `projects:list` |
| US-03-AC-02 | Creating Estimation Parameters | `parameters:list`, `parameters:create`, `projects:show`, `projects:list` |
| US-03-AC-03 | Updating Estimation Parameters | `parameters:list`, `parameters:update`, `projects:show`, `projects:list` |
| US-03-AC-04 | Deleting Estimation Parameters | `parameters:list`, `parameters:delete`, `projects:show`, `projects:list` |

## User Experience Flow

### Happy Path: Creating an Estimation Parameter

1. User navigates to projects page
2. User selects a project to view details
3. User navigates to the Parameters section
4. User clicks "Create" action
5. System displays parameter creation form in a modal/frame
6. User enters a unique parameter title (within the project)
7. User submits the form
8. System validates input (including uniqueness of title within the project)
9. System creates the parameter
10. System shows success message
11. System displays the new parameter in the list

### Alternative Path: Validation Error

1. User attempts to create or update a parameter with invalid data (e.g., missing required title, duplicate title)
2. System validates the form
3. System displays validation error messages inline in the form
4. User corrects the errors
5. User resubmits the form
6. System processes the valid submission

## Parameter Purpose

Estimation parameters represent variables that can be associated to a scaled category during estimation. The value estimated for the effort in this category is then scaled by the value associated with the parameter in scenario evaluation.