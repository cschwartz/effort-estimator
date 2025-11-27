class Project < ApplicationRecord
  has_many :efforts, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :parameters, dependent: :destroy
  has_one :estimation_session, -> { where(status: :active) }, dependent: :destroy

  validates :title, presence: true

  broadcasts_refreshes

  def effort_leaves
    leaves = []
    efforts.roots.each do |root|
      collect_leaves_dfs(root, leaves)
    end
    leaves
  end

  private

  def collect_leaves_dfs(node, leaves)
    if node.leaf?
      leaves << node
    else
      node.children.each { |child| collect_leaves_dfs(child, leaves) }
    end
  end
end
