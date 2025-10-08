# frozen_string_literal: true

module Actions
  class EditActionComponent < ViewComponent::Base
    def initialize(href:, turbo_frame: nil, size: nil, **options)
      @href = href
      @turbo_frame = turbo_frame
      @size = size
      @options = options
    end

    def call
      link_to "Edit", href, **link_options
    end

    def href
      @href.respond_to?(:call) ? @href.call : @href
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
end
