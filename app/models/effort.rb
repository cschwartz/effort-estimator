class Effort < ApplicationRecord
  belongs_to :project
  has_closure_tree order: :position, dependent: :destroy, numeric_order: true

  broadcasts_refreshes

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  def next_estimatable_effort
    all_leaves = collect_all_leaves_in_dfs_order
    current_index = all_leaves.index(self)
    all_leaves[current_index + 1] if current_index
  end

  private

  def collect_all_leaves_in_dfs_order
    leaves = []
    project.efforts.roots.each do |root|
      collect_leaves_dfs(root, leaves)
    end
    leaves
  end

  def collect_leaves_dfs(node, leaves)
    if node.leaf?
      leaves << node
    else
      node.children.each { |child| collect_leaves_dfs(child, leaves) }
    end
  end
end
