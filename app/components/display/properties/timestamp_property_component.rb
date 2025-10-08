# frozen_string_literal: true

module Display
  module Properties
    class TimestampPropertyComponent < ViewComponent::Base
      def initialize(label:, value:, format: :long, css_class: nil)
        @label = label
        @value = value
        @format = format
        @css_class = css_class
      end

      def dd_class
        @css_class || "text-sm text-base-content/80"
      end

      def formatted_value
        case @format
        when :long
          @value.strftime("%B %d, %Y at %I:%M %p")
        when :short
          @value.strftime("%b %d, %Y")
        when :date
          @value.strftime("%B %d, %Y")
        when :time
          @value.strftime("%I:%M %p")
        else
          @value.to_s
        end
      end
    end
  end
end
