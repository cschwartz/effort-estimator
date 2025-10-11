# frozen_string_literal: true

module Forms
  class NestedFormComponent < ViewComponent::Base
    renders_one :add_button

    def initialize(
      form:,
      association_name:,
      label:,
      field_partial:,
      container_id: nil,
      add_button_label: nil,
      wrapper_selector: ".nested-form-wrapper"
    )
      @form = form
      @association_name = association_name
      @label = label
      @field_partial = field_partial
      @container_id = container_id || association_name.to_s
      @add_button_label = add_button_label || derive_add_button_label
      @wrapper_selector = wrapper_selector
    end

    def association_model
      @form.object.class.reflect_on_association(@association_name).klass
    end

    private

    def derive_add_button_label
      singular = @label.singularize
      "Add #{singular}"
    end
  end
end
