# frozen_string_literal: true

module EstimationSessionUi
  class StepsIndicatorComponent < ViewComponent::Base
    class StepComponent < ViewComponent::Base
      def initialize(label:, css_class:)
        @label = label
        @css_class = css_class
      end

      def call
        tag.li(@label, class: @css_class)
      end
    end

    renders_many :steps, StepComponent
  end
end
