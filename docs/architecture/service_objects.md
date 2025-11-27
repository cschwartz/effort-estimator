# Service Objects Architecture

Service objects encapsulate complex business logic that doesn't belong in models or controllers. This document outlines best practices for writing, maintaining, and testing service objects.

## Core Principles

### 1. Single Responsibility

Each service object should have one clear, well-defined purpose.

```ruby
# Good: Focused on session creation
class EstimationSessionCreator
  def call
    create_session
    find_first_leaf_effort
    create_facilitator_participant
    create_effort_estimates
    activate_first_category
  end
end

# Bad: Doing too much
class EstimationManager
  def call
    create_session
    process_votes
    send_notifications
    generate_reports
  end
end
```

### 2. No Database Queries in Views or Components

**NEVER query the database from view components.** All data must be passed in from controllers or other models.

```ruby
# Bad: Component queries database
class ProjectListComponent < ViewComponent::Base
  def initialize
    @projects = Project.all  # NEVER do this
  end
end

# Good: Data passed in
class ProjectListComponent < ViewComponent::Base
  def initialize(projects:)
    @projects = projects
  end
end

# Controller provides data
def index
  @projects = Project.all
end
```

### 3. Transaction Safety

Use ActiveRecord transactions to ensure data integrity when performing multiple database operations.

```ruby
def call
  ActiveRecord::Base.transaction do
    create_session
    create_participants
    create_estimates

    if @errors.any?
      raise ActiveRecord::Rollback
    end
  end

  build_result
end
```

### 4. Explicit Result Objects

Return structured result objects with clear success/failure states and error messages.

```ruby
# Using OpenStruct for simple cases
OpenStruct.new(
  success: @errors.empty?,
  session: @session,
  errors: @errors
)

# Access in controller
if result.success  # Note: not result.success? (OpenStruct uses attributes, not methods)
  # ...
end
```

## Service Object Structure

### File Organization

```
app/services/
├── estimation_session_creator.rb
├── estimation_session_updater.rb
└── vote_processor.rb
```

### Basic Template

```ruby
# app/services/my_service.rb
class MyService
  # Class method for easy calling
  def self.call(**args)
    new(**args).call
  end

  # Initialize with all required dependencies
  def initialize(resource:, user:, params:)
    @resource = resource
    @user = user
    @params = params
    @errors = []
  end

  # Main execution method
  def call
    ActiveRecord::Base.transaction do
      perform_operation_1
      perform_operation_2
      perform_operation_3

      if @errors.any?
        raise ActiveRecord::Rollback
      end
    end

    build_result
  end

  private

  # Break down logic into focused private methods
  def perform_operation_1
    # Implementation
    unless some_condition
      @errors << "Error message"
    end
  end

  def build_result
    OpenStruct.new(
      success: @errors.empty?,
      resource: @resource,
      errors: @errors
    )
  end
end
```

## Usage Patterns

### In Controllers

```ruby
class EstimationSessionsController < ApplicationController
  def create
    result = EstimationSessionCreator.call(
      project: @project,
      facilitator: current_user,
      estimation_option: EstimationOption.find(estimation_session_params[:estimation_option_id])
    )

    if result.success
      redirect_to project_estimation_session_path(@project), notice: "Estimation session started successfully."
    else
      @estimation_session = result.session
      @estimation_options = EstimationOption.all
      flash.now[:alert] = result.errors.join(", ")
      render :new, status: :unprocessable_content
    end
  end
end
```

### Error Handling

```ruby
private

def create_session
  @session = EstimationSession.new(
    project: @project,
    facilitator: @facilitator,
    estimation_option: @estimation_option,
    status: :active
  )

  unless @session.save
    @errors.concat(@session.errors.full_messages)
  end
end

def create_facilitator_participant
  return if @errors.any?  # Early return if previous steps failed

  participant = @session.session_participants.build(
    user: @facilitator,
    joined_at: Time.current,
    status: :active
  )

  unless participant.save
    @errors.concat(participant.errors.full_messages)
  end
end
```

## Testing Service Objects

### What to Test

- **Success scenarios**: Valid inputs produce expected results
- **Failure scenarios**: Invalid inputs return errors
- **Edge cases**: Boundary conditions, empty collections
- **Transaction rollback**: Failed operations don't persist partial data
- **State changes**: Objects are created/updated correctly
- **Business logic**: Complex calculations and workflows

### What NOT to Test

- Framework behavior (ActiveRecord already tested)
- Simple delegations
- Private method internals (test through public interface)

### Example Spec Structure

```ruby
# spec/services/estimation_session_creator_spec.rb
require "rails_helper"

RSpec.describe EstimationSessionCreator do
  describe ".call" do
    let(:project) { create(:project) }
    let(:facilitator) { create(:user) }
    let(:estimation_option) { create(:estimation_option) }

    context "with valid inputs" do
      let!(:category) { create(:category, project: project) }
      let!(:leaf_effort) { create(:effort, project: project, parent: nil) }

      it "returns success: true" do
        result = described_class.call(
          project: project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        expect(result.success).to be true
      end

      it "creates an estimation session" do
        expect {
          described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )
        }.to change(EstimationSession, :count).by(1)
      end

      it "sets the session attributes correctly" do
        result = described_class.call(
          project: project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        session = result.session
        expect(session.project).to eq(project)
        expect(session.facilitator).to eq(facilitator)
        expect(session.estimation_option).to eq(estimation_option)
      end
    end

    context "with invalid inputs" do
      context "when project has no efforts" do
        let!(:category) { create(:category, project: project) }

        it "returns success: false" do
          result = described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )

          expect(result.success).to be false
        end

        it "includes an error message" do
          result = described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )

          expect(result.errors).to include("Project must have at least one leaf effort to estimate")
        end

        it "rolls back the session creation" do
          described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )

          expect(EstimationSession.count).to eq(0)
        end
      end
    end

    context "transaction rollback" do
      let!(:category) { create(:category, project: project) }
      let!(:leaf_effort) { create(:effort, project: project, parent: nil) }

      it "rolls back all changes on error" do
        # Stub to force an error during participant creation
        allow_any_instance_of(SessionParticipant).to receive(:save).and_return(false)
        allow_any_instance_of(SessionParticipant).to receive(:errors).and_return(
          double(full_messages: ["Forced error"])
        )

        expect {
          described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )
        }.not_to change(EstimationSession, :count)

        expect(EffortEstimate.count).to eq(0)
      end
    end
  end
end
```

## Common Patterns

### Building Related Records

```ruby
def create_effort_estimates
  return if @errors.any?

  # Get all leaf efforts in DFS order
  all_leaves = []
  @project.efforts.roots.each do |root|
    collect_leaves_dfs(root, all_leaves)
  end

  # Create estimates for all categories × all leaf efforts
  all_leaves.each do |effort|
    @project.categories.each do |category|
      estimate = @session.effort_estimates.build(
        effort: effort,
        category: category,
        status: :pending
      )

      unless estimate.save
        @errors.concat(estimate.errors.full_messages)
      end
    end
  end
end
```

### Conditional Logic Based on State

```ruby
def activate_first_category
  return if @errors.any?
  return unless @session.current_effort

  first_estimate = @session.effort_estimates
    .where(effort: @session.current_effort)
    .order(:category_id)
    .first

  return unless first_estimate

  # Set initial state based on category type
  if first_estimate.category.scaled?
    first_estimate.status = :parameter_selection
  else
    first_estimate.status = :voting
  end

  unless first_estimate.save
    @errors.concat(first_estimate.errors.full_messages)
  end
end
```

### Tree Traversal (DFS)

```ruby
def collect_leaves_dfs(node, leaves)
  if node.leaf?
    leaves << node
  else
    node.children.each { |child| collect_leaves_dfs(child, leaves) }
  end
end
```

## When to Use Service Objects

### Good Use Cases

- **Complex creation workflows**: Creating multiple related records with specific ordering
- **Multi-step business processes**: Session initialization, order processing, workflow transitions
- **Coordinating multiple models**: Operations spanning several models
- **External service integration**: API calls, email sending, file processing
- **Complex validations**: Business rules that span multiple models
- **Batch operations**: Processing collections with rollback requirements

### When NOT to Use Service Objects

- **Simple CRUD**: Standard create/update/delete handled by controllers
- **Single model operations**: Logic that belongs in the model
- **View logic**: Use view components or helpers instead
- **One-line delegations**: Just call the method directly

## Best Practices

### 1. Keep Services Focused

```ruby
# Good: One clear purpose
class EstimationSessionCreator
  def call
    # Focus: Create session with all initial setup
  end
end

# Avoid: Multiple unrelated operations
class SessionManager
  def call
    create_session
    send_emails
    generate_reports
    cleanup_old_data
  end
end
```

### 2. Early Returns for Failed Preconditions

```ruby
def create_facilitator_participant
  return if @errors.any?  # Don't proceed if previous step failed

  participant = @session.session_participants.build(
    user: @facilitator,
    joined_at: Time.current,
    status: :active
  )

  unless participant.save
    @errors.concat(participant.errors.full_messages)
  end
end
```

### 3. Collect Errors, Don't Raise Immediately

```ruby
# Good: Collect all errors
def create_session
  @session = EstimationSession.new(attributes)

  unless @session.save
    @errors.concat(@session.errors.full_messages)
  end
end

# Avoid: Early raise (prevents collecting all errors)
def create_session
  @session = EstimationSession.new(attributes)
  raise "Session invalid" unless @session.save
end
```

### 4. Use Descriptive Method Names

```ruby
# Good: Clear intent
def find_first_leaf_effort
def create_facilitator_participant
def activate_first_category

# Avoid: Vague names
def process
def handle
def do_stuff
```

### 5. Document Complex Algorithms

```ruby
def find_first_leaf_effort
  return if @errors.any?

  # Get all root efforts and traverse DFS to find first leaf
  # We use DFS (depth-first search) to ensure consistent ordering:
  # - Visit each root effort
  # - Recursively explore children before siblings
  # - Collect leaves in order encountered
  leaves = []
  @project.efforts.roots.each do |root|
    collect_leaves_dfs(root, leaves)
  end

  if leaves.empty?
    @errors << "Project must have at least one leaf effort to estimate"
    return
  end

  @session.current_effort = leaves.first
  unless @session.save
    @errors.concat(@session.errors.full_messages)
  end
end
```

## Result Object Patterns

### Using OpenStruct (Simple Cases)

```ruby
OpenStruct.new(
  success: @errors.empty?,
  session: @session,
  errors: @errors
)

# Access in controller
if result.success  # Note: .success (attribute), not .success? (method)
  # ...
end
```

### Using Custom Result Class (Complex Cases)

```ruby
# app/services/result.rb
class ServiceResult
  attr_reader :resource, :errors

  def initialize(resource:, errors: [])
    @resource = resource
    @errors = errors
  end

  def success?
    @errors.empty?
  end

  def failure?
    !success?
  end

  def error_messages
    @errors.join(", ")
  end
end

# In service object
ServiceResult.new(
  resource: @session,
  errors: @errors
)

# In controller
if result.success?  # Now we can use .success? (method)
  # ...
end
```

## Anti-patterns to Avoid

### 1. Service Objects That Are Just Model Methods

```ruby
# Bad: Should be a model method
class ProjectTitleFormatter
  def self.call(project)
    project.title.titleize
  end
end

# Good: Model method
class Project
  def formatted_title
    title.titleize
  end
end
```

### 2. Modifying Passed-In Objects

```ruby
# Bad: Mutates input
def call
  @project.title = "Modified"
  @project.save
end

# Good: Explicit about changes
def call
  @session = EstimationSession.new(
    project: @project,
    title: @params[:title]
  )
end
```

### 3. Fat Service Objects

```ruby
# Bad: Too many responsibilities
class SessionProcessor
  def call
    create_session
    send_notifications
    update_analytics
    cleanup_old_sessions
    generate_reports
    sync_to_external_api
  end
end

# Good: Split into focused services
EstimationSessionCreator.call(...)
SessionNotifier.call(...)
AnalyticsUpdater.call(...)
```

### 4. Mixing UI Logic with Business Logic

```ruby
# Bad: Service knows about flash messages
def call
  # ...
  flash[:notice] = "Success!"  # Don't do this
end

# Good: Controller handles UI concerns
result = MyService.call(...)
if result.success
  flash[:notice] = "Success!"
end
```

## Extending Service Objects

### Adding New Services

1. Create service file in `app/services/`
2. Follow the standard template (class method `.call`, instance method `#call`)
3. Use transactions for multi-step operations
4. Return structured result objects
5. Add comprehensive specs in `spec/services/`

### Composing Services

```ruby
class ComplexWorkflow
  def call
    ActiveRecord::Base.transaction do
      result1 = Step1Service.call(...)
      return result1 unless result1.success

      result2 = Step2Service.call(...)
      return result2 unless result2.success

      # Continue with workflow
    end
  end
end
```

## Resources

- [Service Objects in Rails](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)
- [Refactoring: Replace Method with Method Object](https://refactoring.com/catalog/replaceMethodWithMethodObject.html)
- [Service Object Pattern](https://medium.com/@scottdomes/service-objects-in-rails-75ca74214b77)
