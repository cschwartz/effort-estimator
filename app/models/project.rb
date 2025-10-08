class Project < ApplicationRecord
  has_many :efforts, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :parameters, dependent: :destroy

  validates :title, presence: true

  broadcasts_refreshes
end
