class Category < ApplicationRecord
  belongs_to :project

  enum :category_type, { scaled: 0, absolute: 1 }

  validates :title, presence: true, uniqueness: { scope: :project_id }
  validates :category_type, presence: true

  broadcasts_refreshes
end
