# frozen_string_literal: true

module EstimationSessionUi
  class CurrentEffortComponent < ViewComponent::Base
    def initialize(effort:)
      @effort = effort
    end
  end
end
