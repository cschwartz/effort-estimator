class Parameter < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :title, uniqueness: { scope: :project_id }

  broadcasts_refreshes
end
