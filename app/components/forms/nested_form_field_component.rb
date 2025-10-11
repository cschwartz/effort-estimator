# frozen_string_literal: true

module Forms
  class NestedFormFieldComponent < ViewComponent::Base
    def initialize(
      form:,
      remove_button_label: "Remove",
      remove_button_variant: :error
    )
      @form = form
      @remove_button_label = remove_button_label
      @remove_button_variant = remove_button_variant
    end

    def wrapper_classes
      "nested-form-wrapper flex items-center gap-2"
    end

    def remove_button_classes
      "btn btn-sm btn-#{@remove_button_variant} btn-outline"
    end
  end
end
