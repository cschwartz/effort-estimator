# Models Architecture

Models are the core of the application's business logic, built on Active Record. This document outlines best practices for writing, maintaining, and extending models.

## Core Principles

### 1. Models Own Business Logic

Models are the single source of truth for business rules. Domain logic belongs in models, not controllers or views.

```ruby
# Good: Business logic in model
class Project < ApplicationRecord
  def can_start_estimation?
    categories.any? && estimation_options.any? && efforts.any?
  end
end

# Usage in controller
if @project.can_start_estimation?
  # proceed
end
```

### 2. Validate at Both Database and Model Levels

Use both database constraints (for data integrity) and model validations (for user feedback).

```ruby
# Migration
add_index :categories, [:project_id, :title], unique: true

# Model
class Category < ApplicationRecord
  validates :title, presence: true, uniqueness: { scope: :project_id }
end
```

### 3. Broadcasting Strategies

Choose the appropriate broadcasting strategy for real-time updates:

- **`broadcasts_refreshes`**: Simple case - refresh the entire element when model changes
- **`broadcasts_to`**: Complex case - custom stream targeting, multiple subscribers, granular control

```ruby
# Simple: Refresh the whole project card when it changes
class Project < ApplicationRecord
  broadcasts_refreshes
end

# Complex: Multiple users watching the same estimation session
class SessionParticipant < ApplicationRecord
  broadcasts_to ->(session_participant) { ["session_participants"] }, insert_by: :append
end
```

## Association Patterns

### belongs_to

Always validate presence unless explicitly optional.

```ruby
class EstimationSession < ApplicationRecord
  belongs_to :project
  belongs_to :facilitator, class_name: "User"
  belongs_to :current_effort, class_name: "Effort", optional: true

  validates :project_id, presence: true
  validates :facilitator_id, presence: true
end
```

### has_many with Dependent Destroy

Always specify dependent behavior for child records.

```ruby
class Project < ApplicationRecord
  has_many :categories, dependent: :destroy
  has_many :estimation_sessions, dependent: :destroy
end
```

### has_many :through

For join models with additional attributes.

```ruby
class EstimationSession < ApplicationRecord
  has_many :session_participants, dependent: :destroy
  has_many :users, through: :session_participants
end
```

## Validation Strategies

### Standard Validations

```ruby
class Project < ApplicationRecord
  validates :title, presence: true
  validates :description, length: { maximum: 1000 }
end
```

### Conditional Validations

For validations that depend on state or related data:

```ruby
class EffortEstimate < ApplicationRecord
  validates :estimation_option_value_id, presence: true, if: :finalized?
  validates :parameter_id, presence: true, if: :requires_parameter?

  private

  def requires_parameter?
    category.scaled? && !parameter_selection?
  end
end
```

**Key Pattern**: When validation conditions become complex, extract to a method rather than using a lambda. This improves readability and testability.

### Scoped Uniqueness

For uniqueness within a parent or scope:

```ruby
class Category < ApplicationRecord
  validates :title, presence: true, uniqueness: { scope: :project_id }
end

class EstimationVote < ApplicationRecord
  validates :user_id, uniqueness: { scope: [:effort_estimate_id, :estimation_session_id] }
end
```

## Enums

### Basic Pattern

```ruby
class EstimationSession < ApplicationRecord
  enum :status, { active: 0, completed: 1 }, default: :active
end
```

**Best Practices**:
- Use integer backing for database efficiency
- Always specify default value
- Use explicit hash syntax for clarity
- Prefix with table name if ambiguous (e.g., `estimate_status:`)

### State Machine Pattern

Enums work well for simple state machines:

```ruby
class EffortEstimate < ApplicationRecord
  enum :status, {
    parameter_selection: 0,
    voting: 1,
    revealed: 2,
    finalized: 3
  }, default: :parameter_selection
end
```

## Nested Attributes

Use `accepts_nested_attributes_for` for forms that manage child records.

```ruby
class EstimationOption < ApplicationRecord
  has_many :estimation_option_values, dependent: :destroy
  accepts_nested_attributes_for :estimation_option_values, allow_destroy: true
end
```

**Controller Strong Parameters**:
```ruby
def estimation_option_params
  params.require(:estimation_option).permit(
    :title,
    estimation_option_values_attributes: [:id, :value, :_destroy]
  )
end
```

**Key Points**:
- Include `:id` to allow updates to existing nested records
- Include `:_destroy` to allow removal of nested records
- Use `allow_destroy: true` in model declaration

## Hierarchical Data with closure_tree

For tree structures (e.g., effort breakdown), use the `closure_tree` gem.

```ruby
class Effort < ApplicationRecord
  belongs_to :project
  has_closure_tree order: :position

  validates :title, presence: true
end
```

### Tree Positioning

Use `prepend_sibling` and `append_sibling` for reordering:

```ruby
# In model or service object
effort.prepend_sibling(target_sibling)  # Move before target
effort.append_sibling(target_sibling)   # Move after target
```

**Note**: The `TreePositioning` controller concern currently handles this logic but should be moved closer to the model layer (e.g., a service object or model method) as a best practice.

## Callbacks

Use callbacks sparingly - they can create hard-to-trace side effects.

**Good use cases**:
- Broadcasting changes (e.g., `after_save_commit :broadcast_update`)
- Setting defaults (though consider database defaults first)
- Cleanup (e.g., deleting associated files)

**Avoid**:
- Complex business logic (use service objects instead)
- Callbacks that modify other models
- Callbacks that can fail (breaks transactions)

```ruby
class EffortEstimate < ApplicationRecord
  after_save_commit :broadcast_update

  private

  def broadcast_update
    broadcast_replace_to estimation_session,
      target: "category-#{category.title.parameterize}",
      partial: "estimation_sessions/effort_estimate",
      locals: { effort_estimate: self, estimation_session: estimation_session, is_facilitator: false }
  end
end
```

## Scopes

Define reusable query patterns as scopes:

```ruby
class Effort < ApplicationRecord
  scope :roots, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position) }
end

# Usage
@efforts = project.efforts.roots.ordered
```

## Domain Methods

Encapsulate business logic in well-named methods:

```ruby
class SessionParticipant < ApplicationRecord
  def is_facilitator?
    estimation_session.facilitator == user
  end
end

class EstimationSession < ApplicationRecord
  def title
    "Estimation Session"
  end
end
```

## Common Patterns

### Display Names for UI

**If an entity has a name to be displayed in UI, provide a `title` attribute.** This ensures consistency across the application.

```ruby
# Database column approach
class Project < ApplicationRecord
  validates :title, presence: true
end

# Method approach (when title is derived)
class EstimationSession < ApplicationRecord
  def title
    "Estimation Session for #{project.title}"
  end
end

# Polymorphic approach (when different models need display names)
class Category < ApplicationRecord
  def title
    # Already has title column
    self[:title]
  end
end

class Parameter < ApplicationRecord
  def title
    # Already has title column
    self[:title]
  end
end
```

**Why `title`?**
- Consistent naming across models
- Clear semantic meaning (what users see)
- Works well with ViewComponents and helpers
- Searchable and sortable

### Counter Caches

For frequently accessed counts:

```ruby
class Project < ApplicationRecord
  has_many :efforts, dependent: :destroy
end

class Effort < ApplicationRecord
  belongs_to :project, counter_cache: true
end

# Migration
add_column :projects, :efforts_count, :integer, default: 0
```

### Timestamps

Active Record adds `created_at` and `updated_at` automatically. Use them:

```ruby
# In queries
Project.where("created_at > ?", 1.week.ago)

# In display
<%= time_ago_in_words(project.created_at) %>
```

## Testing

### What to Test

- **Validations**: Presence, uniqueness, format, conditional
- **Associations**: Correct relationships, dependent behavior
- **Domain methods**: Business logic returns correct results
- **Scopes**: Query results match expectations
- **State transitions**: Enum changes work correctly

### What NOT to Test

- Framework behavior (Active Record already tested)
- Simple attribute readers/writers
- Database constraints (covered by integration tests)

### Example Model Spec

```ruby
RSpec.describe EffortEstimate, type: :model do
  describe "validations" do
    it { should validate_presence_of(:effort_id) }
    it { should validate_presence_of(:estimation_session_id) }
    it { should validate_presence_of(:category_id) }

    context "when finalized" do
      subject { build(:effort_estimate, status: :finalized) }
      it { should validate_presence_of(:estimation_option_value_id) }
    end
  end

  describe "associations" do
    it { should belong_to(:effort) }
    it { should belong_to(:estimation_session) }
    it { should belong_to(:category) }
  end

  describe "#requires_parameter?" do
    it "returns true when category is scaled and not in parameter selection" do
      category = create(:category, category_type: :scaled)
      estimate = create(:effort_estimate, category: category, status: :voting)
      expect(estimate.send(:requires_parameter?)).to be true
    end
  end
end
```

## Anti-patterns to Avoid

### 1. Fat Callbacks

```ruby
# Bad: Complex logic in callback
after_save :do_many_things

def do_many_things
  update_related_records
  send_notifications
  recalculate_totals
  # ... more logic
end

# Good: Use service object
after_save_commit :trigger_update_service

def trigger_update_service
  EstimateUpdateService.call(self)
end
```

### 2. Validation Logic in Controllers

```ruby
# Bad: Business rules in controller
def create
  @project = Project.new(project_params)
  if project_params[:title].blank?
    @project.errors.add(:title, "can't be blank")
    render :new
    return
  end
  @project.save
end

# Good: Validation in model
class Project < ApplicationRecord
  validates :title, presence: true
end
```

### 3. Direct Position Updates

```ruby
# Bad: Updating position directly
effort.update(position: 1)

# Good: Using closure_tree methods
effort.prepend_sibling(target_effort)
```

### 4. Skipping Validations

```ruby
# Bad: Bypassing validations
project.save(validate: false)
project.update_column(:title, new_title)

# Good: Fix the validation or handle errors
if project.save
  # success
else
  # handle errors
end
```

## Extending Models

### Adding New Attributes

1. Create migration
2. Add validation if needed
3. Update strong parameters in controller
4. Update form view
5. Add tests

### Adding New Associations

1. Create migration (foreign key, index)
2. Add `belongs_to` or `has_many`
3. Specify `dependent:` behavior
4. Add inverse_of if needed
5. Update strong parameters for nested attributes
6. Add tests

### Adding New States

1. Add to enum hash
2. Update state machine tests
3. Add any conditional validations
4. Update UI to handle new state
5. Consider broadcasting strategy

## Resources

- [Active Record Basics](https://guides.rubyonrails.org/active_record_basics.html)
- [Active Record Validations](https://guides.rubyonrails.org/active_record_validations.html)
- [Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
- [closure_tree gem](https://github.com/ClosureTree/closure_tree)
