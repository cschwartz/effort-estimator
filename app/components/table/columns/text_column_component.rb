# frozen_string_literal: true

module Table
  module Columns
    class TextColumnComponent < ColumnComponent
      def initialize(header:, value:, css_class: nil)
        super(header: header, css_class: css_class)
        @value = value
      end
    end
  end
end
