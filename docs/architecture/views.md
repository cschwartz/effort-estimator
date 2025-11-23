# Views and Turbo Architecture

Views handle the presentation layer, rendering HTML templates with data from controllers. This application uses Hotwire (Turbo + Stimulus) for a modern, reactive user experience without complex JavaScript frameworks. This document outlines best practices for views, Turbo Frames, Turbo Streams, and real-time updates.

## Core Principles

### 1. Views Delegate to Components

Views should be thin wrappers that delegate to ViewComponents for reusable UI patterns.

```erb
<!-- Good: Delegates to components -->
<%= render Layout::IndexViewComponent.new(
  resource_class: Project,
  collection: @projects,
  row_component: Table::Rows::ProjectRowComponent,
  headers: ["Title", "Actions"],
  new_path: new_project_path
) %>

<!-- Bad: Inline markup in view -->
<div class="container">
  <h1>Projects</h1>
  <table>
    <% @projects.each do |project| %>
      <tr>
        <td><%= project.title %></td>
      </tr>
    <% end %>
  </table>
</div>
```

### 2. Hotwire-First Architecture

Use Turbo for navigation, form submissions, and updates without writing custom JavaScript.

- **Turbo Drive**: Automatic page navigation via fetch requests
- **Turbo Frames**: Scoped page updates (forms, inline editing)
- **Turbo Streams**: Targeted DOM updates (CRUD operations, real-time)

### 3. Progressive Enhancement

HTML should work without JavaScript, then enhance with Turbo.

```erb
<!-- Works without JS, enhanced with Turbo -->
<%= link_to "Projects", projects_path %>

<!-- Works without JS, enhanced with Turbo for inline editing -->
<%= link_to "Edit", edit_project_path(@project),
    data: { turbo_frame: dom_id(Project.new) } %>
```

### 4. Semantic HTML with Utility Classes

Use semantic HTML elements with Tailwind/DaisyUI utility classes.

```erb
<!-- Good: Semantic elements with utilities -->
<article class="card bg-base-100">
  <header class="card-title">
    <h2><%= @project.title %></h2>
  </header>
  <section class="card-body">
    <p><%= @project.description %></p>
  </section>
</article>

<!-- Bad: Div soup -->
<div class="card bg-base-100">
  <div class="card-title">
    <div><%= @project.title %></div>
  </div>
</div>
```

## View Structure

### Standard Resource Views

```
app/views/projects/
├── index.html.erb           # List view
├── show.html.erb            # Detail view
├── new.html.erb             # New form wrapper
├── edit.html.erb            # Edit form wrapper
├── _form.html.erb           # Shared form partial
├── _project.html.erb        # Partial for rendering single item
├── create.turbo_stream.erb  # Turbo Stream for create action
├── update.turbo_stream.erb  # Turbo Stream for update action
└── destroy.turbo_stream.erb # Turbo Stream for destroy action
```

### View Patterns

#### Index View

```erb
<%= render Layout::IndexViewComponent.new(
  resource_class: Project,
  collection: @projects,
  row_component: Table::Rows::ProjectRowComponent,
  headers: ["Title", "Actions"],
  new_path: new_project_path
) %>
```

**Pattern**: Single component renders entire index page (header, table, turbo_frame for forms).

#### Show View

```erb
<%= render Layout::ShowViewComponent.new(
  record: @project,
  actions: [
    render(Actions::EditActionComponent.new(
      href: edit_project_path(@project),
      turbo_frame: dom_id(Project.new)
    )),
    render(Actions::DeleteActionComponent.new(
      href: project_path(@project)
    ))
  ]
) do %>
  <%= render Display::PropertyListComponent.new do |list| %>
    <% list.with_property_prose(
      label: "Description",
      value: @project.description,
      css_class: "description prose prose-sm max-w-none bg-base-200 rounded p-3"
    ) %>
  <% end %>
<% end %>
```

**Pattern**: ShowViewComponent with actions array and block content for custom sections. All actions (including primary actions like "Start Estimation") should be in the actions array, not in the block content.

#### New/Edit Views

```erb
<!-- new.html.erb -->
<%= render Layout::FormViewComponent.new(record: @project) do %>
  <%= render partial: "form", locals: { project: @project } %>
<% end %>

<!-- edit.html.erb -->
<%= render Layout::FormViewComponent.new(record: @project) do %>
  <%= render partial: "form", locals: { project: @project } %>
<% end %>
```

**Pattern**: Thin wrappers that render the shared form partial.

#### Form Partial

```erb
<!-- _form.html.erb -->
<%= simple_form_for project, wrapper: :vertical_form do |f| %>
  <%= render Forms::FormErrorsComponent.new(project) %>
  <%= f.input :title, input_html: { autofocus: true } %>
  <%= f.input :description %>
  <%= link_to "Cancel", projects_path, class: "btn btn-warning" %>
  <%= f.submit %>
<% end %>
```

**Key points**:
- Use `simple_form_for` with `wrapper: :vertical_form`
- Render `FormErrorsComponent` for validation errors
- **Do NOT add** `data: { turbo_stream: true }` (Turbo handles this)
- Include cancel link

#### Item Partial

```erb
<!-- _project.html.erb -->
<%= render Table::Rows::ProjectRowComponent.new(record: project) %>
```

**Pattern**: Delegate to TableRowComponent for consistent rendering.

## Turbo Frames

Turbo Frames enable scoped page updates without full page reloads.

### When to Use Turbo Frames

- **New/Edit forms**: Inline form rendering
- **Form validation errors**: Re-render form in frame
- **Scoped navigation**: Update specific page sections

### Turbo Frame Pattern

#### Index View with Frame

```erb
<!-- Already handled by IndexViewComponent -->
<%= render Layout::IndexViewComponent.new(...) %>

<!-- Component renders this internally: -->
<%= turbo_frame_tag Resource.new %>
```

The frame starts empty and is targeted by "Create" and "Edit" actions.

#### Form in Frame

Forms rendered inside the frame automatically scope their response:

```erb
<!-- new.html.erb renders inside frame -->
<%= render Layout::FormViewComponent.new(record: @project) do %>
  <%= render partial: "form", locals: { project: @project } %>
<% end %>
```

**Key behavior**:
- When form submits with validation errors, controller renders `:new` or `:edit` with `:unprocessable_content` status
- Turbo automatically replaces frame content with the error response (HTML)
- **No turbo_stream format needed for errors**

#### Breaking Out of Frames

To navigate away from a frame (e.g., link to show page):

```erb
<%= link_to resource.title, resource_path(resource),
    data: { turbo_frame: "_top" },
    class: "link link-hover" %>
```

`data: { turbo_frame: "_top" }` breaks out of the frame and navigates the full page.

### DOM ID Helpers

Use `dom_id` for consistent frame and element IDs:

```ruby
dom_id(Project.new)         # => "new_project"
dom_id(@project)            # => "project_123"
dom_id(@project, :edit)     # => "edit_project_123"
```

## Turbo Streams

Turbo Streams enable targeted DOM updates for successful CRUD operations.

### When to Use Turbo Streams

- **Successful create**: Add new item to list
- **Successful update**: Replace item in list
- **Successful destroy**: Remove item from list
- **Flash messages**: Display notifications
- **Real-time updates**: Broadcast changes via WebSockets

### Turbo Stream Actions

- `append`: Add element to end of container
- `prepend`: Add element to start of container
- `replace`: Replace element with new content
- `update`: Replace element's content (not the element itself)
- `remove`: Delete element from DOM

### Create Pattern

```erb
<!-- create.turbo_stream.erb -->
<%= turbo_stream.update Project.new, "" %>
<%= turbo_stream.append "projects", partial: "project", locals: { project: @project } %>
<%= turbo_stream.remove "empty" %>
<%= render_turbo_stream_flash_messages %>
```

**Steps**:
1. Clear the new form frame
2. Append new project to list
3. Remove empty state message (if present)
4. Display flash message

### Update Pattern

```erb
<!-- update.turbo_stream.erb -->
<%= turbo_stream.update Project.new, "" %>
<%= turbo_stream.replace dom_id(@project), partial: "project", locals: { project: @project } %>
<%= render_turbo_stream_flash_messages %>
```

**Steps**:
1. Clear the edit form frame
2. Replace existing project in list with updated version
3. Display flash message

### Destroy Pattern

```erb
<!-- destroy.turbo_stream.erb -->
<%= turbo_stream.remove dom_id(@project) %>
<%= render_turbo_stream_flash_messages %>
```

**Steps**:
1. Remove project from DOM
2. Display flash message

### Flash Messages Helper

```ruby
# app/helpers/application_helper.rb
def render_turbo_stream_flash_messages
  turbo_stream.prepend "flash", partial: "layouts/flash"
end
```

```erb
<!-- app/views/layouts/_flash.html.erb -->
<% flash.each do |flash_type, message| %>
  <%= render Layout::FlashMessageComponent.new(flash_type: flash_type, message: message) %>
<% end %>
```

**Pattern**: Prepend flash messages to `#flash` container in layout.

### Turbo Stream Targets

Use semantic IDs for stream targets:

```erb
<!-- Container for list items -->
<tbody id="projects">
  <%= render @projects %>
</tbody>

<!-- Individual items with dom_id -->
<tr id="<%= dom_id(project) %>">
  <!-- ... -->
</tr>

<!-- Flash container -->
<div id="flash">
  <%= render "layouts/flash" %>
</div>
```

## Real-Time Updates with Turbo Streams

Enable real-time collaboration using Turbo Streams over WebSockets.

### Broadcasting from Models

```ruby
class SessionParticipant < ApplicationRecord
  broadcasts_to ->(session_participant) { ["session_participants"] },
                insert_by: :append
end
```

**Pattern**: Use `broadcasts_to` with custom stream name for real-time updates.

### Subscribing to Streams

```erb
<%= turbo_stream_from @estimation_session %>
```

**Effect**: Subscribe to all Turbo Stream broadcasts for `@estimation_session`.

### Custom Broadcasts from Controllers/Models

```ruby
# In model callback or service object
broadcast_replace_to estimation_session,
  target: "category-#{category.title.parameterize}",
  partial: "estimation_sessions/effort_estimate",
  locals: { effort_estimate: self, estimation_session: estimation_session }
```

**Use cases**:
- State transitions (voting → revealed)
- Multi-user updates
- Progress tracking

## Layouts

### Application Layout

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <meta name="turbo-refresh-method" content="morph">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>
  <body>
    <div class="drawer drawer-open">
      <div class="drawer-content flex flex-col">
        <main>
          <div id="flash">
            <%= render "layouts/flash" %>
          </div>
          <main class="drawer p-4">
            <%= yield %>
          </main>
        </main>
      </div>
      <div class="drawer-side">
        <%= render Navigation::MenuComponent.new do |menu| %>
          <!-- Navigation items -->
        <% end %>
      </div>
    </div>
  </body>
</html>
```

**Key elements**:
- `turbo-refresh-method: morph` - Morphing page refreshes (preserves scroll, focus)
- `#flash` container for flash messages
- Drawer layout with sidebar navigation
- `yield` for page content

### Nested Resource Layouts

For nested resources, pass parent resources to components:

```erb
<%= render Layout::IndexViewComponent.new(
  resource_class: Category,
  collection: @categories,
  row_component: Table::Rows::CategoryRowComponent,
  headers: ["Title", "Type", "Actions"],
  new_path: new_project_category_path(@project),
  parent_resources: [@project]
) %>
```

## Partials

### When to Use Partials

- **Shared forms**: `_form.html.erb`
- **List items**: `_project.html.erb`
- **Reusable sections**: `_flash.html.erb`

### When to Use Components

- **Reusable UI patterns**: Actions, forms, tables
- **Complex logic**: Property lists, menus
- **Testable units**: Components have RSpec tests

**Rule of thumb**: If it's used in one place, use a partial. If it's reusable across resources, use a component.

### Partial Conventions

```erb
<!-- Pass explicit locals -->
<%= render partial: "form", locals: { project: @project } %>

<!-- Collection rendering -->
<%= render @projects %>
<!-- Rails automatically renders app/views/projects/_project.html.erb -->
```

## Helpers

### Application Helper

```ruby
module ApplicationHelper
  include Rails.application.routes.url_helpers

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash", partial: "layouts/flash"
  end
end
```

**Best practices**:
- Keep helpers minimal
- Prefer component methods over view helpers
- Use helpers for framework integration (Turbo Streams, routes)

### Breadcrumbs Helper

```erb
<%= breadcrumbs(@project) %>
# => Projects > 123

<%= breadcrumbs(@project, Category) %>
# => Projects > 123 > Categories

<%= breadcrumbs(@project, @category) %>
# => Projects > 123 > Categories > Foo
```

Handled by `BreadcrumbsComponent`.

## Form Patterns

### Simple Form

```erb
<%= simple_form_for @project, wrapper: :vertical_form do |f| %>
  <%= render Forms::FormErrorsComponent.new(@project) %>
  <%= f.input :title, input_html: { autofocus: true } %>
  <%= f.input :description %>
  <%= link_to "Cancel", projects_path, class: "btn btn-warning" %>
  <%= f.submit %>
<% end %>
```

**Key points**:
- Use `wrapper: :vertical_form` (configured in `config/initializers/simple_form.rb`)
- Always render `FormErrorsComponent`
- Submit button automatically styled as `btn btn-primary`
- **Do NOT add** `data: { turbo_stream: true }` to forms in turbo_frames

### Nested Forms

```erb
<%= simple_form_for @estimation_option do |f| %>
  <%= f.input :title %>

  <%= render Forms::NestedFormComponent.new(
    form: f,
    association_name: :estimation_option_values,
    label: "Values",
    field_partial: "estimation_options/value_field"
  ) %>

  <%= f.submit %>
<% end %>
```

See [Nested Form Components](view_components.md#nested-form-components) for details.

### Boolean Inputs

```erb
<%= f.input :remember_me,
           as: :boolean,
           label: "Remember me",
           hint: "(Stay logged in on this device)" %>
```

Renders as: `☐ Remember me (Stay logged in on this device)`

## Best Practices

### 1. Use ViewComponents for Reusability

```erb
<!-- Good: Reusable component -->
<%= render Actions::CreateActionComponent.new(href: new_project_path) %>

<!-- Bad: Inline markup repeated across views -->
<a href="<%= new_project_path %>" class="btn btn-primary">Create</a>
```

### 2. Keep Views Thin

```erb
<!-- Good: Delegate to components -->
<%= render Layout::IndexViewComponent.new(...) %>

<!-- Bad: Complex logic in view -->
<% if @projects.any? %>
  <table>
    <% @projects.each do |project| %>
      <!-- Complex markup -->
    <% end %>
  </table>
<% else %>
  <p>No projects found</p>
<% end %>
```

### 3. Use Semantic Targets for Turbo Streams

```erb
<!-- Good: Semantic ID -->
<tbody id="projects">
  <%= render @projects %>
</tbody>

<!-- Bad: Generic ID -->
<div id="list">
  <%= render @projects %>
</div>
```

### 4. Consistent DOM IDs

Always use `dom_id` for element IDs:

```erb
<!-- Good: Consistent with Rails conventions -->
<tr id="<%= dom_id(project) %>">

<!-- Bad: Manual ID construction -->
<tr id="project-<%= project.id %>">
```

### 5. Progressive Enhancement

```erb
<!-- Good: Works without JavaScript -->
<%= link_to "Edit", edit_project_path(@project),
    data: { turbo_frame: dom_id(Project.new) } %>

<!-- Bad: Requires JavaScript -->
<button onclick="showEditForm(<%= project.id %>)">Edit</button>
```

### 6. Actions in ShowViewComponent

All actions (including primary actions like "Start Estimation") should be passed to the `actions:` parameter:

```erb
<!-- Good: All actions in actions array -->
<%= render Layout::ShowViewComponent.new(
  record: @project,
  actions: [
    render(Actions::CreateActionComponent.new(
      href: new_project_estimation_session_path(@project),
      label: "Start Estimation"
    )),
    render(Actions::EditActionComponent.new(href: edit_project_path(@project))),
    render(Actions::DeleteActionComponent.new(href: project_path(@project)))
  ]
) do %>
  <!-- Only property lists and custom content here -->
<% end %>

<!-- Bad: Action links in block content -->
<%= render Layout::ShowViewComponent.new(...) do %>
  <%= link_to "Start Estimation", new_project_estimation_session_path(@project), class: "btn btn-primary" %>
<% end %>
```

## Anti-patterns to Avoid

### 1. Business Logic in Views

```erb
<!-- Bad: Logic in view -->
<% if @project.categories.any? && @project.efforts.any? %>
  <%= link_to "Start Estimation", new_estimation_path %>
<% end %>

<!-- Good: Logic in model -->
<% if @project.can_start_estimation? %>
  <%= link_to "Start Estimation", new_estimation_path %>
<% end %>
```

### 2. Inline Styles

```erb
<!-- Bad: Inline styles -->
<div style="color: red; font-weight: bold;">
  <%= @project.title %>
</div>

<!-- Good: Utility classes -->
<div class="text-error font-bold">
  <%= @project.title %>
</div>
```

### 3. JavaScript in Views

```erb
<!-- Bad: Inline JavaScript -->
<button onclick="alert('Hello')">Click</button>

<!-- Good: Stimulus controller -->
<button data-controller="notification" data-action="click->notification#show">
  Click
</button>
```

### 4. Duplicated Markup

```erb
<!-- Bad: Repeated markup -->
<div class="card">
  <h2><%= @project.title %></h2>
</div>
<!-- ...repeated in many views... -->

<!-- Good: Component -->
<%= render CardComponent.new(title: @project.title) %>
```

### 5. Adding data: { turbo_stream: true } to Forms

```erb
<!-- Bad: Unnecessary and conflicts with frames -->
<%= simple_form_for @project, data: { turbo_stream: true } do |f| %>
  <!-- ... -->
<% end %>

<!-- Good: Let Turbo handle format negotiation -->
<%= simple_form_for @project do |f| %>
  <!-- ... -->
<% end %>
```

## Testing Views

Views are tested indirectly through:

- **Feature specs (Cucumber)**: End-to-end user workflows
- **Request specs (RSpec)**: Controller responses, not view rendering
- **Component specs (RSpec)**: Component rendering behavior

**What NOT to test**:
- View rendering (too brittle, covered by feature specs)
- HTML structure (covered by component specs)
- Business logic (covered by model specs)

## Resources

- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Turbo Frames](https://turbo.hotwired.dev/handbook/frames)
- [Turbo Streams](https://turbo.hotwired.dev/handbook/streams)
- [Simple Form Documentation](https://github.com/heartcombo/simple_form)
- [ViewComponent Guide](https://viewcomponent.org/guide/)
