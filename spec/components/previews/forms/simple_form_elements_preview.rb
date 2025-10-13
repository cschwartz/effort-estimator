# frozen_string_literal: true

module Forms
  # Mock model classes for previews
  class FormExample
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :text_field, :string
    attribute :email_field, :string
    attribute :password_field, :string
    attribute :number_field, :integer
    attribute :textarea_field, :string
    attribute :select_field, :string
    attribute :remember_me, :boolean
    attribute :newsletter, :boolean
    attribute :terms, :boolean

    validates :text_field, presence: true

    def [](attr)
      public_send(attr)
    end

    def []=(attr, value)
      public_send("#{attr}=", value)
    end

    def to_key
      nil
    end

    def persisted?
      false
    end

    def model_name
      ActiveModel::Name.new(self.class, nil, "form_example")
    end
  end

  # @label Simple Form Elements
  class SimpleFormElementsPreview < ViewComponent::Preview
    # @label All Input Types
    def all_input_types
      @form_example = FormExample.new
      render_with_template locals: {form_example: @form_example}
    end

    # @label Boolean Inputs
    def boolean_inputs
      @form_example = FormExample.new
      render_with_template locals: {form_example: @form_example}
    end
  end
end
