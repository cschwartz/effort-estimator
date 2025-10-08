# frozen_string_literal: true

module Forms
  # @label Form Errors
  class FormErrorsComponentPreview < ViewComponent::Preview
    # @label With Single Error
    def with_single_error
      project = Project.new
      project.errors.add(:title, "can't be blank")
      render Forms::FormErrorsComponent.new(project)
    end

    # @label With Multiple Errors
    def with_multiple_errors
      project = Project.new
      project.errors.add(:title, "can't be blank")
      project.errors.add(:description, "is too short")
      render Forms::FormErrorsComponent.new(project)
    end

    # @label Without Errors
    def without_errors
      project = Project.new
      render Forms::FormErrorsComponent.new(project)
    end
  end
end
