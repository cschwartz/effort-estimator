# frozen_string_literal: true

module Display
  module Properties
    class BadgeListPropertyComponent < ViewComponent::Base
      def initialize(label:, values: [], variant: :outline, size: :lg, css_class: nil)
        @label = label
        @values = Array(values)
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

      def render?
        @values.any?
      end
    end
  end
end
