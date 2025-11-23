# Architecture Documentation

This directory contains detailed documentation about the Effort Estimator application architecture, organized by technical concerns and layers.

## Purpose

Architecture documentation provides:
- **Technical specifications** for implementation patterns
- **Conventions** for maintaining consistency across the codebase
- **Reference material** for understanding how components interact
- **Onboarding material** for developers joining the project

## Documentation Structure

Each document focuses on a specific architectural layer or concern:

### Application Layers

- [**models.md**](models.md) - Domain models, associations, validations, and business logic
- [**controllers.md**](controllers.md) - HTTP request handling, routing, and response patterns
- [**view_components.md**](view_components.md) - Reusable UI components using ViewComponent
- [**views.md**](views.md) - View templates, Turbo Frames, Turbo Streams, and real-time updates
- [**javascript.md**](javascript.md) - Stimulus controllers and client-side interactions

### Testing Layers

- [**testing.md**](testing.md) - Overall testing strategy and philosophy
- [**model_specs.md**](model_specs.md) - Unit testing for models
- [**request_specs.md**](request_specs.md) - Integration testing for controllers
- [**component_specs.md**](component_specs.md) - Testing for ViewComponents
- [**features.md**](features.md) - Acceptance testing with Cucumber
- [**steps.md**](steps.md) - Cucumber step definitions

### Cross-Cutting Concerns

- [**permissions.md**](permissions.md) - Authorization and role-based access control
- [**real_time.md**](real_time.md) - Real-time collaboration using Turbo Streams and broadcasts
- [**state_management.md**](state_management.md) - State machines and workflow management
- [**database.md**](database.md) - Schema design, migrations, and data modeling

## Technology Stack

### Backend Framework
- **Rails 8.0+** - Web application framework
- **Ruby 3.3+** - Programming language
- **SQLite3** - Database (development/test)

### Frontend Stack
- **Hotwire** - Modern web application framework
  - **Turbo** - Page updates without full reloads
  - **Stimulus** - JavaScript framework for sprinkles
- **Tailwind CSS** - Utility-first CSS framework
- **DaisyUI** - Tailwind CSS component library
- **ViewComponent** - Component-based view layer

### Testing Stack
- **RSpec** - Unit and integration testing
- **Cucumber** - Acceptance testing (BDD)
- **Capybara** - Browser automation for feature tests
- **Selenium** - WebDriver for JavaScript testing
- **FactoryBot** - Test data generation

### Development Tools
- **Lookbook** - ViewComponent preview and development
- **Propshaft** - Asset pipeline
- **Importmap** - JavaScript module management

## Architectural Principles

### 1. Hotwire-First Architecture

The application embraces Hotwire (Turbo + Stimulus) for interactive experiences without heavy JavaScript:

- **Turbo Drive**: Accelerates page navigation
- **Turbo Frames**: Updates portions of the page without full reload
- **Turbo Streams**: Enables real-time updates and multiplexed page changes
- **Stimulus**: Adds JavaScript behavior where needed

### 2. Component-Based UI

ViewComponent provides a component architecture for the view layer:

- **Semantic Components**: Components model user intent, not HTML elements
- **Slot-based Composition**: Flexible content areas using `renders_many`
- **Conditional Rendering**: Components control their own visibility
- **Testable**: Components are tested in isolation

### 3. Convention Over Configuration

Following Rails conventions with project-specific patterns:

- **RESTful Resources**: Standard CRUD operations follow REST principles
- **Nested Resources**: Parent-child relationships in routes match data model
- **Naming Conventions**: Consistent naming across models, controllers, views, and tests

### 4. Test-Driven Development

Comprehensive test coverage at multiple levels:

- **Unit Tests (RSpec)**: Models, components, and isolated logic
- **Integration Tests (RSpec)**: Controllers and request handling
- **Acceptance Tests (Cucumber)**: End-to-end user scenarios
- **Outside-In Testing**: Features drive implementation

### 5. Real-Time Collaboration

Built for multi-user real-time interactions:

- **Turbo Streams over WebSockets**: Real-time updates via Solid Cable
- **Broadcasting**: Server-side events broadcast to connected clients
- **Optimistic UI**: Immediate feedback with server confirmation
- **Multi-User Support**: Concurrent user actions handled gracefully

## Further Reading

Refer to individual architecture documents for detailed information on each layer:

- **Application Layers**: models.md, controllers.md, view_components.md, views.md, javascript.md
- **Testing**: testing.md, model_specs.md, request_specs.md, component_specs.md, features.md, steps.md
- **Cross-Cutting**: permissions.md, real_time.md, state_management.md, database.md

For coding conventions and specific patterns, see [CLAUDE.md](../../CLAUDE.md) in the project root.
