# ViewComponents Architecture

ViewComponents provide a component-based approach to building reusable UI elements. This document outlines best practices for writing, maintaining, and extending ViewComponents, including Lookbook previews for component development.

## Core Principles

### 1. Design Components Around User Intent, Not Technology

Components should represent what users want to accomplish, not specific HTML structures.

```ruby
# Good: Semantic, intent-based
Actions::CreateActionComponent
Actions::EditActionComponent
Actions::DeleteActionComponent

# Bad: Technology-focused
LinkComponent
ButtonComponent
IconButtonComponent
```

### 2. Use Slots for Flexible Composition

Use `renders_many` and `renders_one` for content areas that need customization.

```ruby
class PageHeaderComponent < ViewComponent::Base
  renders_many :actions

  def initialize(item)
    @item = item
  end
end

# Usage
<%= render Layout::PageHeaderComponent.new(Project) do |c| %>
  <% c.with_action do %>
    <%= render Actions::CreateActionComponent.new(href: new_project_path) %>
  <% end %>
  <% c.with_action do %>
    <%= render Actions::EditActionComponent.new(href: edit_project_path(@project)) %>
  <% end %>
<% end %>
```

### 3. Hide Implementation Details

Components should expose simple, meaningful parameters and hide complexity.

```ruby
# Good: Simple API, hides Turbo Frame implementation
CreateActionComponent.new(href: new_project_path, turbo_frame: "new_project")

# Bad: Exposes implementation details
CreateActionComponent.new(
  href: new_project_path,
  data: { turbo_frame: "new_project" }
)
```

### 4. Provide Sensible Defaults

Make components easy to use with defaults, but allow customization.

```ruby
class CreateActionComponent < ViewComponent::Base
  def initialize(href:, label: "Create", turbo_frame: nil, size: nil, **options)
    @href = href
    @label = label      # Defaults to "Create"
    @turbo_frame = turbo_frame
    @size = size
    @options = options
  end
end

# Simple usage
<%= render Actions::CreateActionComponent.new(href: new_project_path) %>

# Customized usage
<%= render Actions::CreateActionComponent.new(
  href: new_project_path,
  label: "Add Project",
  turbo_frame: "projects",
  size: :sm
) %>
```

### 5. Use render? for Conditional Rendering

Control component visibility with the `render?` method.

```ruby
class FormErrorsComponent < ViewComponent::Base
  def initialize(model)
    @model = model
  end

  def render?
    @model.errors.any?
  end
end

# Component only renders when model has errors
<%= render Forms::FormErrorsComponent.new(@project) %>
```

## Component Structure

### File Organization

```
app/components/
├── actions/
│   ├── create_action_component.rb
│   ├── create_action_component.html.erb
│   ├── edit_action_component.rb
│   └── ...
├── forms/
│   ├── form_errors_component.rb
│   ├── form_errors_component.html.erb
│   └── ...
├── layout/
│   ├── page_header_component.rb
│   ├── page_header_component.html.erb
│   └── ...
└── display/
    ├── property_list_component.rb
    ├── property_list_component.html.erb
    └── properties/
        ├── text_property_component.rb
        └── ...
```

**Pattern**: Each component has a `.rb` class file and optionally a `.html.erb` template.

### Listing Available Components

To see all components with their paths:

```bash
find app/components -name "*_component.rb" | sed 's|app/components/||' | sort
```

### Namespacing

Use modules to organize related components:

```ruby
# app/components/actions/create_action_component.rb
module Actions
  class CreateActionComponent < ViewComponent::Base
    # ...
  end
end

# Usage
<%= render Actions::CreateActionComponent.new(...) %>
```

## Common Patterns

### Simple Components (No Template)

For simple components that don't need a template, use the `call` method:

```ruby
class CreateActionComponent < ViewComponent::Base
  def initialize(href:, label: "Create", turbo_frame: nil, size: nil, **options)
    @href = href
    @label = label
    @turbo_frame = turbo_frame
    @size = size
    @options = options
  end

  def call
    link_to @label, href, **link_options
  end

  def href
    @href.respond_to?(:call) ? @href.call : @href
  end

  private

  def link_options
    size_class = @size ? "btn-#{@size}" : nil
    css_classes = ["btn", "btn-primary", size_class, @options[:class]].compact.join(" ")
    opts = @options.merge(class: css_classes)
    opts[:data] = (opts[:data] || {}).merge(turbo_frame: @turbo_frame) if @turbo_frame
    opts
  end
end
```

### Components with Templates

For components with more complex markup, use a template:

```ruby
# app/components/forms/form_errors_component.rb
module Forms
  class FormErrorsComponent < ViewComponent::Base
    def initialize(model)
      @model = model
    end

    def render?
      @model.errors.any?
    end

    def error_message
      @model.errors.full_messages.to_sentence.capitalize
    end
  end
end
```

```erb
<!-- app/components/forms/form_errors_component.html.erb -->
<div class="alert alert-error mb-4" role="alert">
  <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
  </svg>
  <div>
    <h3 class="font-bold">Validation Error</h3>
    <div class="text-xs"><%= error_message %></div>
  </div>
</div>
```

### Polymorphic Components

Components that handle different input types:

```ruby
class PageHeaderComponent < ViewComponent::Base
  renders_many :actions

  def initialize(item)
    @item = item
  end

  def title
    case @item
    when Class
      @item.name.pluralize
    when ActiveRecord::Base
      @item.persisted? ? @item.title : "New #{@item.model_name.human}"
    when String
      @item
    end
  end
end

# Usage
<%= render Layout::PageHeaderComponent.new(Project) %>          # "Projects"
<%= render Layout::PageHeaderComponent.new(@project) %>         # "Sample Project"
<%= render Layout::PageHeaderComponent.new(Project.new) %>      # "New Project"
<%= render Layout::PageHeaderComponent.new("Custom Title") %>   # "Custom Title"
```

### Typed Slots (renders_many with Types)

Use typed slots for components that accept different slot types:

```ruby
class PropertyListComponent < ViewComponent::Base
  renders_many :properties, types: {
    text: "Display::Properties::TextPropertyComponent",
    prose: "Display::Properties::ProsePropertyComponent",
    badge: "Display::Properties::BadgePropertyComponent",
    badge_list: "Display::Properties::BadgeListPropertyComponent",
    timestamp: "Display::Properties::TimestampPropertyComponent"
  }

  def initialize(wrapper: true)
    @wrapper = wrapper
  end

  def wrapper?
    @wrapper
  end
end

# Usage
<%= render Display::PropertyListComponent.new do |list| %>
  <% list.with_property_text(label: "Name", value: @project.title) %>
  <% list.with_property_badge(label: "Status", value: "Active") %>
  <% list.with_property_timestamp(label: "Created", value: @project.created_at) %>
<% end %>
```

### Nested Form Components

For handling `accepts_nested_attributes_for` associations:

```ruby
class NestedFormComponent < ViewComponent::Base
  renders_one :add_button

  def initialize(
    form:,
    association_name:,
    label:,
    field_partial:,
    container_id: nil,
    add_button_label: nil,
    wrapper_selector: ".nested-form-wrapper"
  )
    @form = form
    @association_name = association_name
    @label = label
    @field_partial = field_partial
    @container_id = container_id || association_name.to_s
    @add_button_label = add_button_label || derive_add_button_label
    @wrapper_selector = wrapper_selector
  end

  def association_model
    @form.object.class.reflect_on_association(@association_name).klass
  end

  private

  def derive_add_button_label
    singular = @label.singularize
    "Add #{singular}"
  end
end

# Usage in form
<%= render Forms::NestedFormComponent.new(
  form: f,
  association_name: :estimation_option_values,
  label: "Values",
  field_partial: "estimation_options/value_field"
) %>
```

## Lookbook Previews

Lookbook provides a component browser for developing and documenting components.

### Preview Structure

```
spec/components/previews/
├── actions/
│   ├── create_action_component_preview.rb
│   └── create_action_component_preview/
│       ├── with_custom_label.html.erb
│       └── with_turbo_frame.html.erb
├── forms/
│   └── form_errors_component_preview.rb
└── layout/
    ├── page_header_component_preview.rb
    └── page_header_component_preview/
        ├── with_create_action.html.erb
        └── with_edit_and_delete.html.erb
```

### Basic Preview (Ruby Methods)

Use Ruby methods for simple previews without block content:

```ruby
# spec/components/previews/forms/form_errors_component_preview.rb
module Forms
  # @label Form Errors
  class FormErrorsComponentPreview < ViewComponent::Preview
    # @label With Single Error
    def with_single_error
      project = Project.new
      project.errors.add(:title, "can't be blank")
      render Forms::FormErrorsComponent.new(project)
    end

    # @label With Multiple Errors
    def with_multiple_errors
      project = Project.new
      project.errors.add(:title, "can't be blank")
      project.errors.add(:description, "is too short")
      render Forms::FormErrorsComponent.new(project)
    end

    # @label Without Errors
    def without_errors
      project = Project.new
      render Forms::FormErrorsComponent.new(project)
    end
  end
end
```

**When to use Ruby methods**:
- Simple data setup
- Creating mock objects
- No block content or slots
- No nested components

### ERB Template Previews

Use ERB templates for previews that need to render components with slots or block content:

```ruby
# spec/components/previews/layout/page_header_component_preview.rb
module Layout
  # @label Page Header
  class PageHeaderComponentPreview < ViewComponent::Preview
    # @label With Class
    def with_class
      render Layout::PageHeaderComponent.new(Project)
    end

    # @label With Create Action
    def with_create_action; end  # Empty method - template does rendering

    # @label With Edit and Delete Actions
    def with_edit_and_delete; end  # Empty method - template does rendering
  end
end
```

```erb
<!-- spec/components/previews/layout/page_header_component_preview/with_create_action.html.erb -->
<%= render Layout::PageHeaderComponent.new(Project) do |c| %>
  <% c.with_action do %>
    <%= render Actions::CreateActionComponent.new(href: "#", turbo_frame: "new_project") %>
  <% end %>
<% end %>
```

**When to use ERB templates**:
- Rendering components with block content (slots)
- Rendering nested components inside blocks
- Access to view helpers like `render`
- Complex component composition

**Pattern**: Preview class has empty methods, ERB template does the rendering.

### Preview Annotations

Use annotations to organize previews in Lookbook:

```ruby
# @label Form Errors           # Preview group label
class FormErrorsComponentPreview < ViewComponent::Preview
  # @label With Single Error   # Scenario label
  def with_single_error
    # ...
  end

  # @label With Multiple Errors
  def with_multiple_errors
    # ...
  end
end
```

### Mock Data in Previews

Create realistic mock data for previews:

```ruby
def with_persisted_record
  project = Project.new(id: 1, title: "Sample Project")
  project.define_singleton_method(:persisted?) { true }
  render Layout::PageHeaderComponent.new(project)
end

def with_new_record
  project = Project.new(title: "Sample Project")
  render Layout::PageHeaderComponent.new(project)
end
```

### Accessing Lookbook

1. Start development server: `bin/dev`
2. Navigate to `/rails/view_components`
3. Browse components and scenarios
4. View source code and rendered output

## Testing Components

Use RSpec with ViewComponent test helpers.

### What to Test

- **Element presence**: CSS selectors, text content
- **Conditional rendering**: `render?` method behavior
- **CSS class structure**: Critical classes for styling
- **Content transformation**: Capitalization, formatting
- **Slot rendering**: Proper slot behavior

### What NOT to Test

- Exact HTML structure (brittle)
- Implementation details
- Business logic (belongs in model specs)

### Basic Component Spec

```ruby
require "rails_helper"

RSpec.describe Forms::FormErrorsComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:project) { Project.new }

  describe "rendering with errors" do
    before do
      project.errors.add(:title, "can't be blank")
    end

    it "renders the error alert" do
      render_inline(described_class.new(project))

      expect(page).to have_css(".alert.alert-error")
      expect(page).to have_css('[role="alert"]')
    end

    it "renders the error message" do
      render_inline(described_class.new(project))

      expect(page).to have_text("Title can't be blank")
    end
  end

  describe "rendering without errors" do
    it "does not render anything" do
      render_inline(described_class.new(project))

      expect(page).not_to have_css(".alert")
    end
  end
end
```

### Testing Conditional Rendering

```ruby
describe "#render?" do
  it "returns false when model has no errors" do
    component = described_class.new(Project.new)
    expect(component.render?).to be false
  end

  it "returns true when model has errors" do
    project = Project.new
    project.errors.add(:title, "can't be blank")
    component = described_class.new(project)
    expect(component.render?).to be true
  end
end
```

### Testing Slots

```ruby
describe "rendering with actions" do
  it "renders action slots" do
    render_inline(described_class.new(Project)) do |c|
      c.with_action { '<a href="/test" class="btn">Test Action</a>'.html_safe }
    end

    expect(page).to have_css(".flex.gap-2.not-prose")
    expect(page).to have_link("Test Action")
  end

  it "renders multiple action slots" do
    render_inline(described_class.new(Project)) do |c|
      c.with_action { '<a href="/edit" class="btn">Edit</a>'.html_safe }
      c.with_action { '<button class="btn">Delete</button>'.html_safe }
    end

    expect(page).to have_link("Edit")
    expect(page).to have_button("Delete")
  end
end
```

### Testing CSS Structure

```ruby
describe "CSS structure" do
  before do
    project.errors.add(:title, "can't be blank")
  end

  it "renders with correct CSS classes" do
    render_inline(described_class.new(project))

    expect(page).to have_css(".alert.alert-error.mb-4")
    expect(page).to have_css("h3.font-bold")
    expect(page).to have_css("div.text-xs")
  end
end
```

### Testing Content Transformation

```ruby
describe "error message capitalization" do
  before do
    project.errors.add(:title, "can't be blank")
  end

  it "capitalizes the error message" do
    render_inline(described_class.new(project))

    # Verify first letter is uppercase
    expect(page).to have_css("div.text-xs", text: /^[A-Z]/)
  end
end
```

## Best Practices

### 1. Keep Components Focused

Each component should have a single, clear responsibility:

```ruby
# Good: Focused on displaying form errors
class FormErrorsComponent < ViewComponent::Base
  def initialize(model)
    @model = model
  end
end

# Bad: Does too much
class FormComponent < ViewComponent::Base
  def initialize(model, fields, validations, submit_path)
    # Too many responsibilities
  end
end
```

### 2. Avoid Business Logic

Components should focus on presentation, not business rules:

```ruby
# Good: Logic in model
class Project < ApplicationRecord
  def can_start_estimation?
    categories.any? && estimation_options.any? && efforts.any?
  end
end

# Component uses model method
if @project.can_start_estimation?
  # ...
end

# Bad: Business logic in component
class ProjectHeaderComponent < ViewComponent::Base
  def can_start_estimation?
    @project.categories.any? && @project.estimation_options.any? && @project.efforts.any?
  end
end
```

### 3. Use Helpers Judiciously

Prefer component methods over view helpers:

```ruby
# Good: Component method
class PageHeaderComponent < ViewComponent::Base
  def title
    case @item
    when Class
      @item.name.pluralize
    else
      @item.title
    end
  end
end

# OK for Rails helpers: link_to, content_tag, etc.
link_to @label, href, **link_options
```

### 4. Design for Reusability

Make components flexible enough for multiple use cases:

```ruby
# Reusable with sensible defaults and customization options
class CreateActionComponent < ViewComponent::Base
  def initialize(href:, label: "Create", turbo_frame: nil, size: nil, **options)
    # Flexible parameters allow various use cases
  end
end

# Can be used in multiple contexts
<%= render Actions::CreateActionComponent.new(href: new_project_path) %>
<%= render Actions::CreateActionComponent.new(href: new_category_path, label: "Add Category") %>
<%= render Actions::CreateActionComponent.new(href: new_effort_path, size: :xs) %>
```

### 5. Document with Previews

Every component should have at least one preview showing typical usage:

```ruby
class MyComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render MyComponent.new
  end

  # @label With Options
  def with_options
    render MyComponent.new(option: "value")
  end
end
```

## Anti-patterns to Avoid

### 1. Overly Generic Components

```ruby
# Bad: Too generic, loses semantic meaning
class LinkComponent < ViewComponent::Base
  def initialize(href:, label:, style:, icon:, color:)
    # ...
  end
end

# Good: Semantic, purpose-driven
class CreateActionComponent < ViewComponent::Base
  # Clear intent, sensible defaults
end
```

### 2. Components with Too Many Parameters

```ruby
# Bad: Parameter explosion
def initialize(href:, label:, style:, size:, color:, icon:, position:, variant:, theme:)
  # ...
end

# Good: Focused parameters, sensible defaults
def initialize(href:, label: "Create", turbo_frame: nil, size: nil, **options)
  # ...
end
```

### 3. Mixing Concerns

```ruby
# Bad: Component handles data fetching
class ProjectListComponent < ViewComponent::Base
  def initialize
    @projects = Project.all  # Don't fetch data in components
  end
end

# Good: Data passed in
class ProjectListComponent < ViewComponent::Base
  def initialize(projects:)
    @projects = projects
  end
end
```

### 4. Deep Component Nesting

```ruby
# Bad: Too many levels
<%= render OuterComponent.new do %>
  <%= render MiddleComponent.new do %>
    <%= render InnerComponent.new do %>
      <%= render DeepComponent.new %>
    <% end %>
  <% end %>
<% end %>

# Good: Flatter structure
<%= render OuterComponent.new do |c| %>
  <% c.with_content do %>
    <%= render ContentComponent.new %>
  <% end %>
<% end %>
```

## Extending Components

### Adding New Components

1. Create component class in appropriate namespace
2. Create template if needed
3. Add preview with multiple scenarios
4. Add specs for behavior and rendering
5. Document in CLAUDE.md if widely used

### Adding Slots

```ruby
class MyComponent < ViewComponent::Base
  renders_one :header
  renders_many :items

  def initialize(title:)
    @title = title
  end
end

# Usage
<%= render MyComponent.new(title: "My Title") do |c| %>
  <% c.with_header do %>
    <h2>Header Content</h2>
  <% end %>
  <% c.with_item do %>
    <p>Item 1</p>
  <% end %>
  <% c.with_item do %>
    <p>Item 2</p>
  <% end %>
<% end %>
```

### Subclassing Components

```ruby
# Base component
class ButtonComponent < ViewComponent::Base
  def initialize(label:, **options)
    @label = label
    @options = options
  end
end

# Specialized component
class PrimaryButtonComponent < ButtonComponent
  def initialize(label:, **options)
    super(label: label, **options.merge(class: "btn-primary"))
  end
end
```

## Resources

- [ViewComponent Documentation](https://viewcomponent.org/)
- [ViewComponent Guide](https://viewcomponent.org/guide/)
- [Lookbook Documentation](https://lookbook.build/)
- [Testing ViewComponents](https://viewcomponent.org/guide/testing.html)
