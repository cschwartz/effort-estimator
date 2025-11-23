class EstimationVote < ApplicationRecord
  belongs_to :effort
  belongs_to :estimation_session
  belongs_to :category
  belongs_to :user
  belongs_to :estimation_option_value

  validates :effort_id, presence: true
  validates :estimation_session_id, presence: true
  validates :category_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: [ :effort_id, :estimation_session_id, :category_id ] }
  validates :estimation_option_value_id, presence: true
  validates :voted_at, presence: true
end
