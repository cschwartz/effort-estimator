# Controllers Architecture

Controllers handle HTTP requests and coordinate between models and views. This document outlines best practices for writing, maintaining, and extending controllers in a Hotwire-based Rails application.

## Core Principles

### 1. Controllers Coordinate, Models Contain Logic

Controllers orchestrate the flow, but business logic belongs in models or service objects.

```ruby
# Bad: Business logic in controller
def create
  @project = Project.new(project_params)
  @project.status = :active
  @project.created_by = current_user.id
  if @project.categories.any? && @project.efforts.any?
    @project.ready_for_estimation = true
  end
  @project.save
end

# Good: Logic in model
def create
  @project = Project.new(project_params)
  @project.prepare_for_user(current_user)
  @project.save
end
```

### 2. Thin Controllers

Keep actions focused on a single responsibility. Complex setup logic belongs in service objects.

```ruby
# Complex - candidate for service object (from EstimationSessionsController)
def create
  @estimation_session = @project.build_estimation_session(estimation_session_params)
  @estimation_session.facilitator = current_user
  @estimation_session.status = :active

  first_leaf = Effort.roots.where(project: @project).flat_map(&:leaves).first
  @estimation_session.current_effort = first_leaf

  if @estimation_session.save
    @estimation_session.session_participants.create!(
      user: current_user,
      joined_at: Time.current,
      status: :active
    )

    @project.categories.each do |category|
      @estimation_session.effort_estimates.create!(
        effort: first_leaf,
        category: category,
        status: :parameter_selection
      )
    end

    redirect_to project_estimation_session_path(@project), notice: "Estimation session started successfully."
  else
    @estimation_options = EstimationOption.all
    render :new, status: :unprocessable_content
  end
end

# Better: Extract to service object
def create
  result = EstimationSessionCreator.call(
    project: @project,
    facilitator: current_user,
    params: estimation_session_params
  )

  if result.success?
    redirect_to project_estimation_session_path(@project), notice: "Estimation session started successfully."
  else
    @estimation_session = result.session
    @estimation_options = EstimationOption.all
    render :new, status: :unprocessable_content
  end
end
```

### 3. Follow REST Conventions

Stick to the seven standard REST actions whenever possible:

- `index` - List resources
- `show` - Display a single resource
- `new` - Form for creating a resource
- `create` - Create a resource
- `edit` - Form for editing a resource
- `update` - Update a resource
- `destroy` - Delete a resource

Only add custom actions when REST doesn't fit naturally.

## Standard Resource Controller Pattern

### Top-Level Resource

```ruby
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.all
  end

  def show; end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      respond_to do |format|
        format.html { redirect_to projects_path, notice: "Project was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Project was successfully created." }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      respond_to do |format|
        format.html { redirect_to projects_path, notice: "Project was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Project was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_path, notice: "Project was successfully deleted." }
      format.turbo_stream { flash.now[:notice] = "Project was successfully deleted." }
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end
end
```

### Nested Resource

```ruby
class CategoriesController < ApplicationController
  before_action :set_project
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = @project.categories.order(:created_at)
  end

  def show; end

  def new
    @category = @project.categories.build
  end

  def create
    @category = @project.categories.build(category_params)

    if @category.save
      respond_to do |format|
        format.html { redirect_to project_categories_path(@project), notice: "Category was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Category was successfully created." }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      respond_to do |format|
        format.html { redirect_to project_categories_path(@project), notice: "Category was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Category was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to project_categories_path(@project), notice: "Category was successfully deleted." }
      format.turbo_stream { flash.now[:notice] = "Category was successfully deleted." }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_category
    @category = @project.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:title, :category_type)
  end
end
```

**Key patterns for nested resources**:
- Always set the parent resource first: `before_action :set_project`
- Scope child queries through parent: `@project.categories.find(params[:id])`
- Use `build` instead of `new` for creating children: `@project.categories.build`
- Redirect to nested path: `project_categories_path(@project)`

## Hotwire Response Patterns

### Turbo Frames vs Turbo Streams

**Use Turbo Frames for**:
- New/Edit forms (inline editing)
- Form validation errors (re-render form in frame)

**Use Turbo Streams for**:
- Successful create/update/destroy actions
- Real-time updates to lists
- Flash messages

### Response Pattern

```ruby
def create
  @resource = Resource.new(resource_params)

  if @resource.save
    respond_to do |format|
      # HTML: Traditional redirect with flash in session
      format.html { redirect_to resources_path, notice: "Resource was successfully created." }

      # Turbo Stream: Set flash.now for immediate rendering
      format.turbo_stream { flash.now[:notice] = "Resource was successfully created." }
    end
  else
    # Validation error: Return HTML for turbo_frame to render
    # No turbo_stream format needed - frame expects HTML
    render :new, status: :unprocessable_content
  end
end
```

**Key points**:
- Success responses support both HTML (redirect) and turbo_stream formats
- Use `flash[:notice]` for HTML redirects (stored in session)
- Use `flash.now[:notice]` for turbo_stream responses (immediate rendering)
- Validation errors return `:unprocessable_content` status (not `:unprocessable_entity`)
- No turbo_stream format for validation errors - the turbo_frame expects HTML

### Flash Messages

```ruby
# HTML format - stored in session for next request
format.html { redirect_to path, notice: "Success message" }

# Turbo Stream format - available immediately in rendered view
format.turbo_stream { flash.now[:notice] = "Success message" }
```

## Before Actions

### Common Patterns

```ruby
class CategoriesController < ApplicationController
  # Set parent resource for all actions
  before_action :set_project

  # Set resource for specific actions
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # Load data needed by multiple actions
  before_action :set_categories, only: [:index, :new, :edit, :show, :update, :create]
end
```

### Order Matters

Before actions run in order of declaration:

```ruby
before_action :set_project      # Runs first
before_action :set_category     # Can use @project
```

### Skip Actions in Subclasses

```ruby
class PublicProjectsController < ProjectsController
  skip_before_action :authenticate_user!
end
```

## Strong Parameters

Always use strong parameters to prevent mass assignment vulnerabilities.

### Basic Pattern

```ruby
def project_params
  params.require(:project).permit(:title, :description)
end
```

### Nested Attributes

```ruby
def estimation_option_params
  params.require(:estimation_option).permit(
    :title,
    estimation_option_values_attributes: [:id, :value, :_destroy]
  )
end
```

**Key points**:
- Include `:id` to allow updates to existing nested records
- Include `:_destroy` to allow removal of nested records
- Match the model's `accepts_nested_attributes_for` configuration

### Arrays

```ruby
def project_params
  params.require(:project).permit(:title, category_ids: [])
end
```

## Concerns

Extract shared behavior into controller concerns.

### Example: TreePositioning

```ruby
# app/controllers/concerns/tree_positioning.rb
module TreePositioning
  extend ActiveSupport::Concern

  def update_tree_position(node, roots, new_position, new_parent_id, find_parent_node)
    updated_node = if new_parent_id.blank?
      move_to_root_position(node, roots, new_position)
    else
      new_parent = find_parent_node.call(new_parent_id)
      move_to_parent_position(node, new_parent, new_position)
    end

    not updated_node.nil?
  end

  private

  def move_to_root_position(node, nodes, position)
    # Implementation...
  end

  def move_to_parent_position(node, new_parent, position)
    # Implementation...
  end
end

# Usage in controller
class EffortsController < ApplicationController
  include TreePositioning

  def update
    if update_effort
      respond_to do |format|
        format.html { redirect_to project_efforts_path(@project) }
        format.turbo_stream { flash.now[:notice] = "Effort was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def update_effort
    @effort.transaction do
      if effort_params.key?(:parent_id) || effort_params.key?(:position)
        new_parent_id = effort_params[:parent_id]
        new_position = effort_params[:position].to_i

        unless update_tree_position(@effort, @project.efforts, new_position, new_parent_id,
                                     lambda { |parent_id| @project.efforts.find(parent_id) })
          @effort.errors.add(:base, "Invalid effort position")
          raise ActiveRecord::Rollback
        end
      end

      other_params = effort_params.except(:parent_id, :position)
      return true if other_params.empty?
      @effort.update(other_params)
    end
  rescue ActiveRecord::Rollback
    false
  end
end
```

**Note**: While controller concerns work for shared behavior, complex logic like tree positioning should ideally live closer to the model layer (e.g., in a service object or model method) rather than in a controller concern.

## Query Optimization

### N+1 Query Prevention

Use `includes` to eager load associations:

```ruby
def index
  # Bad: N+1 queries when rendering children
  @efforts = @project.efforts.roots

  # Good: Eager load children
  @efforts = @project.efforts.roots.includes(:children)
end
```

### Ordering

Apply ordering in controllers when it's view-specific, in models when it's default behavior:

```ruby
# Controller: View-specific ordering
def index
  @categories = @project.categories.order(:created_at)
end

# Model: Default ordering via scope
class Effort < ApplicationRecord
  scope :ordered, -> { order(:position) }
end

# Controller uses scope
def index
  @efforts = @project.efforts.roots.ordered
end
```

## Error Handling

### Rescue from Exceptions

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    redirect_to root_path, alert: "Record not found"
  end
end
```

### Conditional Redirects

```ruby
def show
  @estimation_session = @project.estimation_session
  redirect_to new_project_estimation_session_path(@project) if @estimation_session.nil?
end
```

## Instance Variables

### Guidelines

- Use instance variables (`@project`) to pass data from controller to view
- Minimize the number of instance variables (ideally 1-2 per action)
- Use descriptive names
- Set in `before_action` when used by multiple actions

```ruby
# Good: Clear, minimal instance variables
def show
  # @project already set by before_action
end

# Bad: Too many instance variables, unclear purpose
def show
  @project = Project.find(params[:id])
  @categories = @project.categories
  @category_count = @categories.count
  @has_categories = @category_count > 0
  @efforts = @project.efforts
  @sessions = @project.estimation_sessions
end

# Better: Let view/components query as needed, or use view models
def show
  @project = Project.find(params[:id])
end
```

## ApplicationController

Common configuration and behavior for all controllers.

```ruby
class ApplicationController < ActionController::Base
  # Security
  allow_browser versions: :modern

  # Authentication
  before_action :authenticate_user!

  # Layout selection
  layout :layout_by_resource

  private

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
```

## Testing Controllers

Use request specs to test controllers (not controller specs).

### What to Test

- HTTP status codes
- Database changes
- Flash messages
- Redirects
- Response formats (HTML, turbo_stream)

### What NOT to Test

- View rendering (covered by feature specs)
- Business logic (covered by model specs)
- HTML content (covered by component/feature specs)

### Example Request Spec

```ruby
RSpec.describe "Categories", type: :request do
  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }
  let(:turbo_stream_content_type) { "text/vnd.turbo-stream.html" }
  let(:project) { create(:project) }

  describe "POST /projects/:project_id/categories" do
    context "with valid parameters" do
      let(:valid_attributes) { { title: "New Category", category_type: :scaled } }

      it "creates a new category" do
        expect {
          post project_categories_path(project), params: { category: valid_attributes }
        }.to change(Category, :count).by(1)
      end

      it "redirects to the categories index" do
        post project_categories_path(project), params: { category: valid_attributes }
        expect(response).to redirect_to(project_categories_path(project))
      end

      it "sets a success notice" do
        post project_categories_path(project), params: { category: valid_attributes }
        expect(flash[:notice]).to eq("Category was successfully created.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          post project_categories_path(project),
               params: { category: valid_attributes },
               headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          post project_categories_path(project),
               params: { category: valid_attributes },
               headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Category was successfully created.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not create a new category" do
        expect {
          post project_categories_path(project), params: { category: invalid_attributes }
        }.not_to change(Category, :count)
      end

      it "returns unprocessable content status" do
        post project_categories_path(project), params: { category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
```

## Common Patterns

### Redirecting After Actions

```ruby
# Top-level resource
redirect_to projects_path

# Nested resource
redirect_to project_categories_path(@project)

# Show specific resource
redirect_to project_path(@project)
```

### Setting Data for Forms

```ruby
def new
  @project = Project.new
  @estimation_options = EstimationOption.all  # For select dropdown
end

def create
  @project = Project.new(project_params)

  if @project.save
    # ...
  else
    # Re-set data needed by form
    @estimation_options = EstimationOption.all
    render :new, status: :unprocessable_content
  end
end
```

### Handling Missing Resources

```ruby
def show
  @resource = Resource.find_by(id: params[:id])

  if @resource.nil?
    redirect_to resources_path, alert: "Resource not found"
  end
end

# Or let RecordNotFound exception propagate to ApplicationController
def show
  @resource = Resource.find(params[:id])  # Raises if not found
end
```

## Anti-patterns to Avoid

### 1. Business Logic in Controllers

```ruby
# Bad
def create
  @project = Project.new(project_params)
  @project.status = current_user.admin? ? :active : :pending
  @project.priority = calculate_priority(@project)
  @project.save
end

# Good
def create
  @project = Project.new(project_params)
  @project.prepare_for_user(current_user)
  @project.save
end
```

### 2. Complex Queries in Controllers

```ruby
# Bad
def dashboard
  @overdue_projects = Project.where("due_date < ?", Date.today)
                            .where(status: [:active, :pending])
                            .includes(:categories, :efforts)
                            .order(priority: :desc, due_date: :asc)
end

# Good
def dashboard
  @overdue_projects = Project.overdue.with_associations.by_priority
end
```

### 3. Multiple Render/Redirect Calls

```ruby
# Bad
def create
  @project = Project.new(project_params)
  redirect_to projects_path if @project.save
  render :new unless @project.save  # Won't execute
end

# Good
def create
  @project = Project.new(project_params)

  if @project.save
    redirect_to projects_path
  else
    render :new, status: :unprocessable_content
  end
end
```

### 4. Unnecessary Instance Variables

```ruby
# Bad
def show
  @project = Project.find(params[:id])
  @project_title = @project.title
  @project_created = @project.created_at
  @project_updated = @project.updated_at
end

# Good
def show
  @project = Project.find(params[:id])
  # View can access @project.title, @project.created_at, etc.
end
```

## Extending Controllers

### Adding New Actions

1. Determine if it fits REST (prefer standard actions)
2. Add route in `config/routes.rb`
3. Add action method in controller
4. Create view template if needed
5. Add tests

### Adding Concerns

1. Create concern in `app/controllers/concerns/`
2. Include in controller: `include ConcernName`
3. Use concern methods
4. Add tests for concern behavior

### Custom Response Formats

```ruby
def show
  respond_to do |format|
    format.html
    format.json { render json: @project }
    format.pdf { render pdf: "project-#{@project.id}" }
  end
end
```

## Resources

- [Action Controller Overview](https://guides.rubyonrails.org/action_controller_overview.html)
- [Layouts and Rendering](https://guides.rubyonrails.org/layouts_and_rendering.html)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Hotwire Discussion: Turbo Frames vs Streams](https://discuss.hotwired.dev/)
