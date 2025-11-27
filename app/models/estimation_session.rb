class EstimationSession < ApplicationRecord
  belongs_to :project
  belongs_to :estimation_option
  belongs_to :facilitator, class_name: "User"
  belongs_to :current_effort, class_name: "Effort", optional: true

  has_many :session_participants, dependent: :destroy
  has_many :users, through: :session_participants
  has_many :effort_estimates, dependent: :destroy
  has_many :estimation_votes, dependent: :destroy

  enum :status, { active: 0, completed: 1 }, default: :active

  validates :project_id, presence: true
  validates :estimation_option_id, presence: true
  validates :facilitator_id, presence: true

  def title
    "Estimation Session"
  end
end
