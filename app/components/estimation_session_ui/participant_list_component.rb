module EstimationSessionUi
  class ParticipantListComponent < ViewComponent::Base
    def initialize(participants:, facilitator:)
      @participants = participants
      @facilitator = facilitator
    end

    def is_facilitator?(participant)
      @facilitator == participant.user
    end
  end
end
