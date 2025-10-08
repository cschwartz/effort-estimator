# frozen_string_literal: true

module Table
  module Columns
    class LinkColumnComponent < ColumnComponent
      def initialize(header:, href:, value:, turbo_frame: "_top", css_class: nil)
        super(header: header, css_class: css_class)
        @href = href
        @value = value
        @turbo_frame = turbo_frame
      end
    end
  end
end
