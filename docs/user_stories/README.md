# User Stories Documentation

This directory contains user stories that document the features of the Effort Estimator application. User stories serve as the single source of truth for feature requirements and drive test implementation.

## Purpose

User stories serve as:
- **Primary specification** for feature requirements
- **Living documentation** of application behavior
- **Source material** for Cucumber feature tests
- **Traceability** between business requirements and implementation
- **Onboarding material** for new team members
- **Product specification** for stakeholders

## Development Workflow (Target State)

The intended development workflow is:

1. **Write User Story**: Document the feature requirements in a user story file
2. **Derive Tests**: Create Cucumber feature file based on acceptance criteria
3. **Implement Feature**: Develop the functionality to satisfy the acceptance criteria
4. **Maintain Alignment**: Keep user story and tests synchronized as requirements evolve

### Current Bootstrap Phase

We are currently in a bootstrap phase where existing Cucumber features are being documented as user stories. This temporary reversal allows us to:
- Establish the user story format and conventions
- Document existing implemented features
- Build a foundation for the target workflow

Once bootstrap is complete, new features will follow the target workflow: user story first, then tests.

## Structure

Each user story follows a consistent structure:

### YAML Front Matter

```yaml
---
id: US-XX                          # Unique identifier with leading zeros
feature: Feature Name              # Name of the feature
epic: Epic Name                    # Parent epic grouping
priority: High|Medium|Low          # Business priority
status: Implemented|In Progress    # Current implementation status
test_coverage: path/to/feature     # Path to Cucumber feature file (relative to project root)
related_features:                  # List of related features
  - Feature One
  - Feature Two
---
```

### Document Sections

1. **User Story**: Classic user story format
   - **As a** [user role]
   - **I want to** [action/capability]
   - **So that** [business value/benefit]

2. **Acceptance Criteria**: Detailed requirements with hierarchical IDs
   - Format: `US-XX-AC-YY` (where XX is user story number, YY is acceptance criterion number)
   - Each AC specifies:
     - Starting point/location context (e.g., "In the projects list...")
     - Prerequisites (required permissions)
     - Expected behavior for valid/invalid scenarios
     - Success messages and error handling

3. **Validation Rules**: Table of field-level validation constraints

4. **Permission Requirements**: Table mapping ACs to required permissions
   - Columns: AC ID | Acceptance Criteria | Required Permissions

5. **User Experience Flow**: Step-by-step interaction flows
   - **Happy Path**: Successful completion of primary use case
   - **Alternative Paths**: Error scenarios and edge cases

## Naming Conventions

### File Names
- Use snake_case for file names
- Match feature domain (e.g., `project_management.md`, `category_management.md`)
- Keep names concise but descriptive

### IDs
- **User Story IDs**: `US-XX` (e.g., `US-01`, `US-02`)
- **Acceptance Criteria IDs**: `US-XX-AC-YY` (e.g., `US-01-AC-01`)
- Use double digits with leading zeros for both levels

### Permissions
- Reference permissions using backticks: `` `projects:list` ``
- Use actual permission names from the codebase

## Writing Guidelines

### Acceptance Criteria

1. **Start with location context**: Begin each AC with "In the [location]..." to establish where the interaction occurs
   - Example: "In the projects list, users can delete existing projects"

2. **Specify prerequisites clearly**: List all required permissions upfront

3. **Describe general validation behavior**: Avoid over-specifying individual validation rules
   - Good: "Shows appropriate validation error messages"
   - Avoid: "Shows 'Title can't be blank' when title is empty"

4. **Include both success and failure paths**: Document what happens when things go right and wrong

5. **Use consistent language**:
   - "Users can..." for capabilities
   - "System displays/shows..." for UI feedback
   - "Creates/Updates/Removes..." for data changes

### Validation Rules

Document field-level constraints in a table:
- Field name
- Required (Yes/No)
- Specific constraints (length, format, uniqueness, etc.)

### User Experience Flows

1. **Happy Path**: Describe the most common successful journey
   - Use numbered steps
   - Include system responses
   - End with successful outcome

2. **Alternative Paths**: Document common variations and error scenarios
   - Use validation errors as examples
   - Show recovery paths (how users can correct errors)

## Deriving Cucumber Tests

Cucumber feature files should be derived from user story acceptance criteria:

- **Feature description**: Maps to the user story statement
- **Scenarios**: Created from acceptance criteria
- **Scenario variations**: Test both success and failure paths described in ACs
- **Test data**: Use examples that validate specific validation rules from the table

### Mapping ACs to Scenarios

A single acceptance criterion may generate multiple scenarios:

**Example**: `US-01-AC-03: Creating Projects`
- Scenario: "Create new project" (tests valid submission behavior)
- Scenario: "Create project without title" (tests validation error for required field)

Both scenarios validate different aspects of the same acceptance criterion.

## Traceability

Each user story maintains traceability to:
- **Test Coverage**: Links to Cucumber feature file in `test_coverage` front matter
- **Related Features**: Lists in `related_features` (relationships can be auto-generated)
- **Permissions**: Documented in Permission Requirements table
- **Implementation**: AC IDs can be referenced in code comments and commit messages

## Maintenance

User stories should be:
- **The source of truth** for feature requirements
- **Updated first** when requirements change
- **Versioned** through git alongside code changes
- **Reviewed** as part of pull request process for feature work
- **Referenced** from Cucumber features using AC IDs in comments

When a feature changes:
1. Update the user story acceptance criteria
2. Update the corresponding Cucumber scenarios
3. Implement the changes
4. Ensure tests pass

## Example Reference

See [project_management.md](project_management.md) for a complete example of the user story structure and conventions.
