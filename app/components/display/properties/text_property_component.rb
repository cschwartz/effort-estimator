# frozen_string_literal: true

module Display
  module Properties
    class TextPropertyComponent < ViewComponent::Base
      def initialize(label:, value: nil, css_class: nil)
        @label = label
        @value = value
        @css_class = css_class
      end

      def dd_class
        @css_class || "text-sm text-base-content/80"
      end
    end
  end
end
