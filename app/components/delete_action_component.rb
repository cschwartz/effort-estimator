# frozen_string_literal: true

class DeleteActionComponent < ViewComponent::Base
  def initialize(href:, confirm: "Are you sure?", turbo_method: :delete, size: nil, **options)
    @href = href
    @confirm = confirm
    @turbo_method = turbo_method
    @size = size
    @options = options
  end

  def call
    button_to "Delete", href, **button_options
  end

  def href
    @href.respond_to?(:call) ? @href.call : @href
  end

  private

  def button_options
    size_class = @size ? "btn-#{@size}" : nil
    css_classes = [ "btn", "btn-error", size_class, @options[:class] ].compact.join(" ")
    data = @options[:data] || {}
    data = data.merge(confirm: @confirm) if @confirm
    data = data.merge(turbo_method: @turbo_method) if @turbo_method

    @options.merge(
      method: :delete,
      class: css_classes,
      data: data
    )
  end
end
