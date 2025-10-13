# frozen_string_literal: true

SimpleForm.setup do |config|
  config.generate_additional_classes_for = [:input]

  config.button_class = "btn btn-secondary"

  config.boolean_label_class = ""

  config.label_text = ->(label, required, _explicit_label) { "#{label} #{required}" }

  config.boolean_style = :inline

  config.item_wrapper_tag = :div

  config.include_default_input_wrapper_class = false

  config.error_notification_class = "alert alert-error"

  config.error_method = :to_sentence

  config.input_field_error_class = "input-error"
  config.input_field_valid_class = "input-success"
  config.label_class = "label-text"

  config.browser_validations = false

  config.wrappers :vertical_form, tag: "fieldset", class: "fieldset form-control w-full mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.wrapper tag: "legend", class: "fieldset-legend" do |legend|
      legend.use :label_text
    end
    b.use :input,
          class: "input input-bordered w-full", error_class: "input-error", valid_class: "input-success"
    b.use :full_error, wrap_with: { tag: "div", class: "label" }
    b.use :hint, wrap_with: { tag: "div", class: "label" }
  end

  config.wrappers :vertical_select, tag: "fieldset", class: "fieldset form-control w-full mb-4" do |b|
    b.use :html5
    b.wrapper tag: "legend", class: "fieldset-legend" do |ba|
      ba.use :label_text
    end
    b.use :input, class: "select w-full"
    b.use :hint, wrap_with: { tag: "span", class: "label" }
    b.use :error, wrap_with: { tag: "span", class: "label label-text-alt text-error" }
  end

  config.default_wrapper = :vertical_form

  config.wrapper_mappings = {
    select: :vertical_select,
  }
end
