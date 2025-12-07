# frozen_string_literal: true

module EstimationSessionUi
  class ParameterSelectorComponent < ViewComponent::Base
    def initialize(estimate:, parameters:, is_facilitator:)
      @estimate = estimate
      @parameters = parameters
      @is_facilitator = is_facilitator
    end

    def render?
      @is_facilitator && @estimate.parameter_selection?
    end

    def category
      @estimate.category
    end

    def selected_parameter_id
      @estimate.parameter_id
    end
  end
end
