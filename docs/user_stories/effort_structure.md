---
id: US-05
feature: Effort Tree Structure
epic: Core Platform
priority: High
status: Implemented
test_coverage: features/effort_structure.feature
related_features:
  - Project Management
  - Effort Estimates
---

# User Story: Effort Tree Structure

## User Story

**As a** user
**I want to** manage effort breakdown structures
**So that** I can organize and track project work hierarchically

## Acceptance Criteria

### US-05-AC-01: Viewing Effort Nodes

- In the project's Effort Breakdown section, users with `efforts:list` permission can view the effort tree structure
- Root effort nodes (nodes without a parent) are displayed at the top level
- Users can expand effort nodes to view their children
- Each effort node displays its title

### US-05-AC-02: Creating Effort Nodes

**Prerequisites**: User must have `efforts:create` and `efforts:list` permissions

- In the project's Effort Breakdown section, users can create new root effort nodes
- In the project's Effort Breakdown section, users can create new child effort nodes under an existing parent
- Effort creation form includes:
  - Title field
  - Description field
- Valid effort submission:
  - Creates the effort node in the system
  - Shows success message: "Effort was successfully created"
  - Displays the new effort node in the appropriate location in the tree
- Invalid effort submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not create the effort node

### US-05-AC-03: Updating Effort Nodes

**Prerequisites**: User must have `efforts:update` and `efforts:list` permissions

- In the project's Effort Breakdown section, users can edit existing effort nodes
- Update form pre-fills with current effort node data
- Form includes same fields as creation
- Valid update submission:
  - Updates the effort node in the system
  - Shows success message: "Effort was successfully updated"
  - Displays updated information in the tree
- Invalid update submission:
  - Shows appropriate validation error messages
  - Keeps user on the form to correct errors
  - Does not save the changes

### US-05-AC-04: Deleting Effort Nodes

**Prerequisites**: User must have `efforts:delete` and `efforts:list` permissions

- In the project's Effort Breakdown section, users can delete root effort nodes
- In the project's Effort Breakdown section, users can delete child effort nodes
- Deleting an effort node with children removes all descendants (cascading delete)
- Successful deletion:
  - Removes the effort node and all its descendants from the system
  - Shows success message: "Effort was successfully deleted"
  - Removes the effort node from the tree

### US-05-AC-05: Moving Effort Nodes

**Prerequisites**: User must have `efforts:update` and `efforts:list` permissions

- In the project's Effort Breakdown section, users can reorder effort nodes among their siblings
- In the project's Effort Breakdown section, users can move effort nodes to different parents
- Moving an effort node updates its position in the tree
- The tree structure reflects the new organization after the move

## Validation Rules

| Field | Required | Constraints |
|-------|----------|-------------|
| Title | Yes | Cannot be blank |
| Description | No | Free text |
| Parent | No | Must be a valid effort node in the same project (if specified) |

## Permission Requirements

| AC ID | Acceptance Criteria | Required Permissions |
|-------|---------------------|---------------------|
| US-05-AC-01 | Viewing Effort Nodes | `efforts:list` |
| US-05-AC-02 | Creating Effort Nodes | `efforts:list`, `efforts:create` |
| US-05-AC-03 | Updating Effort Nodes | `efforts:list`, `efforts:update` |
| US-05-AC-04 | Deleting Effort Nodes | `efforts:list`, `efforts:delete` |
| US-05-AC-05 | Moving Effort Nodes | `efforts:list`, `efforts:update` |

## User Experience Flow

### Happy Path: Creating a Hierarchical Effort Structure

1. User navigates to projects page
2. User selects a project to view details
3. User navigates to the Effort Breakdown section
4. User creates a root effort node (e.g., "Backend Development")
5. System displays the new root node in the tree
6. User expands the "Backend Development" node
7. User creates a child effort under "Backend Development" (e.g., "User Authentication")
8. System displays the child node under its parent
9. User can continue adding more nodes to build the hierarchy

### Alternative Path: Validation Error

1. User attempts to create or update an effort node with invalid data (e.g., missing required title)
2. System validates the form
3. System displays validation error messages inline in the form
4. User corrects the errors
5. User resubmits the form
6. System processes the valid submission

### Alternative Path: Reorganizing the Tree

1. User views the effort breakdown tree
2. User decides to move a node to a different location
3. User drags and drops the node to reorder among siblings or to a different parent
4. System updates the tree structure
5. Tree reflects the new organization

## Hierarchical Structure

The effort breakdown structure is a tree where:
- **Root nodes**: Top-level effort items with no parent (e.g., major project phases)
- **Child nodes**: Effort items nested under a parent (e.g., tasks within a phase)
- **Position**: Nodes maintain an order among their siblings for consistent display
- **Cascading delete**: Removing a parent automatically removes all its descendants

This structure supports Work Breakdown Structure (WBS) methodology for decomposing project work into manageable components.
