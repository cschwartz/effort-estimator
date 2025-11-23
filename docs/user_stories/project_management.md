---
id: US-01
feature: Project Management
epic: Core Platform
priority: High
status: Implemented
test_coverage: features/project_management.feature
related_features:
  - Categories
  - Estimation Options
  - Estimation Sessions
---

# User Story: Project Management

## User Story

**As a** project manager
**I want to** create and manage projects in the system
**So that** I can organize and track effort estimations for different initiatives

## Acceptance Criteria

### US-01-AC-01: Listing Projects

- In the projects list, users with `projects:list` permission can view a list of all projects
- Each project displays its title
- When no projects exist, the system shows "No existing Projects" message

### US-01-AC-02: Viewing Project Details

- In the projects list, users with `projects:view` permission can select a project to view its detailed information
- Project details display the project's title and description

### US-01-AC-03: Creating Projects

**Prerequisites**: User must have `projects:create`, `projects:list`, and `projects:view` permissions

- In the projects list, users can initiate project creation
- Project creation form includes:
  - Title field
  - Description field
- Valid project submission:
  - Creates the project in the system
  - Shows success message: "Project was successfully created"
  - Displays the new project in the projects list
  - Redirects to project details
- Invalid project submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not create the project

### US-01-AC-04: Updating Projects

**Prerequisites**: User must have `projects:update`, `projects:list`, and `projects:view` permissions

- In the projects list, users can edit existing projects
- Update form pre-fills with current project data
- Form includes same fields as creation
- Valid update submission:
  - Updates the project in the system
  - Shows success message: "Project was successfully updated"
  - Displays updated information in project details
- Invalid update submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not save the changes

### US-01-AC-05: Deleting Projects

**Prerequisites**: User must have `projects:delete` and `projects:list` permissions

- In the projects list, users can delete existing projects
- Successful deletion:
  - Removes the project from the system
  - Shows success message: "Project was successfully deleted."
  - Removes the project from the projects list

## Validation Rules

| Field | Required | Constraints |
|-------|----------|-------------|
| Title | Yes | Cannot be blank |
| Description | No | Free text |

## Permission Requirements

| AC ID | Acceptance Criteria | Required Permissions |
|-------|---------------------|---------------------|
| US-01-AC-01 | Listing Projects | `projects:list` |
| US-01-AC-02 | Viewing Project Details | `projects:list`, `projects:view` |
| US-01-AC-03 | Creating Projects | `projects:list`, `projects:create`, `projects:view` |
| US-01-AC-04 | Updating Projects | `projects:list`, `projects:update`, `projects:view` |
| US-01-AC-05 | Deleting Projects | `projects:list`, `projects:delete` |

## User Experience Flow

### Happy Path: Creating a Project

1. User navigates to projects page
2. User clicks "Create" action
3. System displays project creation form in a modal/frame
4. User enters project title and description
5. User submits the form
6. System validates input
7. System creates the project
8. System shows success message
9. System displays the new project in the list
10. User can view project details

### Alternative Path: Validation Error

1. User attempts to create or update a project with invalid data (e.g., missing required title)
2. System validates the form
3. System displays validation error messages inline in the form
4. User corrects the errors
5. User resubmits the form
6. System processes the valid submission
