---
id: US-02
feature: Estimation Categories
epic: Core Platform
priority: High
status: Implemented
test_coverage: features/estimation_categories.feature
related_features:
  - Project Management
  - Estimation Options
---

# User Story: Estimation Categories

## User Story

**As a** project manager
**I want to** manage estimation categories for my project
**So that** I can define the components for effort estimation

## Acceptance Criteria

### US-02-AC-01: Listing Estimation Categories

- In the project's Categories section, users with `categories:list` permission can view a list of all estimation categories
- Each category displays its title and type (Scaled or Absolute)
- When no categories exist, the system shows "No existing Categories" message

### US-02-AC-02: Creating Estimation Categories

**Prerequisites**: User must have `categories:create`, `categories:list`, `projects:show`, and `projects:list` permissions

- In the project's Categories section, users can initiate category creation
- Category creation form includes:
  - Title field (must be unique within the project)
  - Type field (Scaled or Absolute)
- Valid category submission:
  - Creates the category in the system
  - Shows success message: "Category was successfully created"
  - Displays the new category in the categories list
- Invalid category submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not create the category

### US-02-AC-03: Updating Estimation Categories

**Prerequisites**: User must have `categories:update`, `categories:list`, `projects:show`, and `projects:list` permissions

- In the project's Categories section, users can edit existing categories
- Update form pre-fills with current category data
- Form includes same fields as creation (title must remain unique within the project)
- Valid update submission:
  - Updates the category in the system
  - Shows success message: "Category was successfully updated"
  - Displays updated information in the categories list
- Invalid update submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not save the changes

### US-02-AC-04: Deleting Estimation Categories

**Prerequisites**: User must have `categories:delete`, `categories:list`, `projects:show`, and `projects:list` permissions

- In the project's Categories section, users can delete existing categories
- Successful deletion:
  - Removes the category from the system
  - Shows success message: "Category was successfully deleted"
  - Removes the category from the categories list

## Validation Rules

| Field | Required | Constraints |
|-------|----------|-------------|
| Title | Yes | Cannot be blank; must be unique within project |
| Type | Yes | Must be either "Scaled" or "Absolute" |

## Permission Requirements

| AC ID | Acceptance Criteria | Required Permissions |
|-------|---------------------|---------------------|
| US-02-AC-01 | Listing Estimation Categories | `categories:list`, `projects:show`, `projects:list` |
| US-02-AC-02 | Creating Estimation Categories | `categories:list`, `categories:create`, `projects:show`, `projects:list` |
| US-02-AC-03 | Updating Estimation Categories | `categories:list`, `categories:update`, `projects:show`, `projects:list` |
| US-02-AC-04 | Deleting Estimation Categories | `categories:list`, `categories:delete`, `projects:show`, `projects:list` |

## User Experience Flow

### Happy Path: Creating an Estimation Category

1. User navigates to projects page
2. User selects a project to view details
3. User navigates to the Categories section
4. User clicks "Create" action
5. System displays category creation form in a modal/frame
6. User enters a unique category title (within the project) and selects type (Scaled or Absolute)
7. User submits the form
8. System validates input (including uniqueness of title within the project)
9. System creates the category
10. System shows success message
11. System displays the new category in the list

### Alternative Path: Validation Error

1. User attempts to create or update a category with invalid data (e.g., missing required title, duplicate title)
2. System validates the form
3. System displays validation error messages inline in the form
4. User corrects the errors
5. User resubmits the form
6. System processes the valid submission

## Category Types

### Scaled
Represents estimation categories that use relative scaling (e.g., with number of assets, number of legal entities). Efforts for scaled categories are multiplied by the parameter associated with the category during the estimation phase.

### Absolute
Represents estimation categories that use absolute values. The efforts estimated during the estimation phase are directly used. 
