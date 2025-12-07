# frozen_string_literal: true

module EstimationSessionUi
  class ParameterDisplayComponent < ViewComponent::Base
    def initialize(estimate:)
      @estimate = estimate
    end

    def render?
      @estimate.parameter.present? && (@estimate.voting? || @estimate.revealed? || @estimate.finalized?)
    end

    def category
      @estimate.category
    end

    def parameter
      @estimate.parameter
    end
  end
end
