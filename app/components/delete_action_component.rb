# frozen_string_literal: true

class DeleteActionComponent < ViewComponent::Base
  def initialize(href:, confirm: "Are you sure?", turbo_method: :delete, **options)
    @href = href
    @confirm = confirm
    @turbo_method = turbo_method
    @options = options
  end

  def call
    button_to "Delete", @href, **button_options
  end

  private

  def button_options
    css_classes = [ "btn", "btn-error", @options[:class] ].compact.join(" ")
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
