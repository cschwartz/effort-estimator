class Effort < ApplicationRecord
  belongs_to :project
  has_closure_tree order: :position, dependent: :destroy

  broadcasts_refreshes

  validates :title, presence: true
end
