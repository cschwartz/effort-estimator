class Effort < ApplicationRecord
  belongs_to :project
  has_closure_tree order: :position, dependent: :destroy, numeric_order: true

  broadcasts_refreshes

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  def next_estimatable_effort
    all_leaves = project.effort_leaves
    current_index = all_leaves.index(self)
    all_leaves[current_index + 1] if current_index
  end
end
