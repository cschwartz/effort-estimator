class EstimationOptionValue < ApplicationRecord
  belongs_to :estimation_option

  validates :value, presence: true,
                    numericality: { only_integer: true, greater_than: 0 },
                    uniqueness: { scope: :estimation_option_id }

  broadcasts_refreshes
end
