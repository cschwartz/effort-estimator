class Project < ApplicationRecord
  has_many :efforts, dependent: :destroy

  validates :title, presence: true
end
