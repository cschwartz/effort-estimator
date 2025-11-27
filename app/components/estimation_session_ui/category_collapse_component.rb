# frozen_string_literal: true

module EstimationSessionUi
  class CategoryCollapseComponent < ViewComponent::Base
    def initialize(estimate:, is_active:)
      @estimate = estimate
      @is_active = is_active
      @status_order = [ :parameter_selection, :voting, :revealed, :finalized ]
      @current_index = @status_order.index(@estimate.status.to_sym) || 0
    end

    def category
      @estimate.category
    end

    def collapse_state
      @is_active ? "collapse-open" : "collapse-close"
    end

    def status_badge_variant
      @estimate.pending? ? :ghost : :primary
    end

    def step_css_class(target_status)
      target_index = @status_order.index(target_status)

      if @current_index >= target_index
        "step step-primary"
      else
        "step"
      end
    end
  end
end
