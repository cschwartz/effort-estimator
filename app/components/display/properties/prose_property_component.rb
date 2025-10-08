# frozen_string_literal: true

module Display
  module Properties
    class ProsePropertyComponent < ViewComponent::Base
      def initialize(label:, value: nil, css_class: nil)
        @label = label
        @value = value
        @css_class = css_class
      end

      def dd_class
        @css_class || "prose prose-sm max-w-none bg-base-200 rounded p-3"
      end
    end
  end
end
