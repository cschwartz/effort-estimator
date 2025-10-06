# frozen_string_literal: true

class EditActionComponent < ViewComponent::Base
  def initialize(href:, turbo_frame: nil, **options)
    @href = href
    @turbo_frame = turbo_frame
    @options = options
  end

  def call
    link_to "Edit", @href, **link_options
  end

  private

  def link_options
    css_classes = [ "btn", "btn-primary", @options[:class] ].compact.join(" ")
    opts = @options.merge(class: css_classes)
    opts[:data] = (opts[:data] || {}).merge(turbo_frame: @turbo_frame) if @turbo_frame
    opts
  end
end
