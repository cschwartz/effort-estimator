# frozen_string_literal: true

class CreateActionComponent < ViewComponent::Base
  def initialize(href:, label: "Create", turbo_frame: nil, size: nil, **options)
    @href = href
    @label = label
    @turbo_frame = turbo_frame
    @size = size
    @options = options
  end

  def call
    link_to @label, @href, **link_options
  end

  private

  def link_options
    size_class = @size ? "btn-#{@size}" : nil
    css_classes = [ "btn", "btn-primary", size_class, @options[:class] ].compact.join(" ")
    opts = @options.merge(class: css_classes)
    opts[:data] = (opts[:data] || {}).merge(turbo_frame: @turbo_frame) if @turbo_frame
    opts
  end
end
