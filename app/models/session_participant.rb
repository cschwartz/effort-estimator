class SessionParticipant < ApplicationRecord
  belongs_to :estimation_session
  belongs_to :user

  enum :status, { active: 0, disconnected: 1, left: 2 }, default: :active

  validates :estimation_session_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :estimation_session_id }
  validates :joined_at, presence: true

  broadcasts_to ->(session_participant) { [ "session_participants" ] }, insert_by: :append

  def is_facilitator?
    estimation_session.facilitator == self.user
  end
end
