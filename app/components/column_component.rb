# frozen_string_literal: true

class ColumnComponent < ViewComponent::Base
  attr_reader :header

  def initialize(header:, css_class: nil)
    @header = header
    @css_class = css_class
  end

  def css_class
    @css_class || header.to_s.parameterize
  end
end
