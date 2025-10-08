# frozen_string_literal: true

module Display
  module Properties
    class BadgePropertyComponent < ViewComponent::Base
      def initialize(label:, value: nil, variant: :outline, size: :lg, css_class: nil)
        @label = label
        @value = value
        @variant = variant
        @size = size
        @css_class = css_class
      end

      def dd_class
        @css_class || @label.parameterize
      end

      def badge_classes
        [ "badge", "badge-#{@variant}", "badge-#{@size}" ].join(" ")
      end
    end
  end
end
