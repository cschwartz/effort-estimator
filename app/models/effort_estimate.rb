class EffortEstimate < ApplicationRecord
  belongs_to :effort
  belongs_to :estimation_session
  belongs_to :category
  belongs_to :parameter, optional: true
  belongs_to :estimation_option_value, optional: true

  enum :status, { pending: 0, parameter_selection: 1, voting: 2, revealed: 3, finalized: 4 }, default: :pending

  validates :effort_id, presence: true
  validates :estimation_session_id, presence: true
  validates :category_id, presence: true, uniqueness: { scope: [ :effort_id, :estimation_session_id ] }
  validates :estimation_option_value_id, presence: true, if: :finalized?
  validates :parameter_id, presence: true, if: -> { category.scaled? && (voting? || revealed? || finalized?) }
end
