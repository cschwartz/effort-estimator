class EstimationOption < ApplicationRecord
  has_many :estimation_option_values, dependent: :destroy

  accepts_nested_attributes_for :estimation_option_values,
                                allow_destroy: true,
                                reject_if: :all_blank

  validates :title, presence: true, uniqueness: true

  broadcasts_refreshes
end
