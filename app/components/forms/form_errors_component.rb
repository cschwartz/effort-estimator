# frozen_string_literal: true

module Forms
  class FormErrorsComponent < ViewComponent::Base
    def initialize(model)
      @model = model
    end

    def render?
      @model.errors.any?
    end

    def error_message
      @model.errors.full_messages.to_sentence.capitalize
    end
  end
end
