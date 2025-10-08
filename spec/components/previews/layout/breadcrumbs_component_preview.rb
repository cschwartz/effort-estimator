# frozen_string_literal: true

module Layout
  # @label Breadcrumbs
  class BreadcrumbsComponentPreview < ViewComponent::Preview
    # Home > Projects
    # @label Class Only
    def class_only
      render Layout::BreadcrumbsComponent.new(Project)
    end

    # Home > Projects > Sample Project
    # @label Persisted Record
    def persisted_record
      project = as_persisted_model(Project.new(id: 1, title: "Sample Project"))
      render Layout::BreadcrumbsComponent.new(project)
    end

    # Home > Projects > Sample Project > Edit
    # @label Record with String
    def record_with_string
      project = as_persisted_model(Project.new(id: 1, title: "Sample Project"))
      render Layout::BreadcrumbsComponent.new(project, "Edit")
    end

    # Home > Projects > Sample Project > Efforts
    # @label Nested Class Resources
    def nested_class_resources
      project = as_persisted_model(Project.new(id: 1, title: "Sample Project"))
      render Layout::BreadcrumbsComponent.new(project, Effort)
    end

    # Home > Projects > Sample Project > Categories
    # @label Parent and Nested Class
    def parent_and_nested_class
      project = as_persisted_model(Project.new(id: 1, title: "Sample Project"))
      render Layout::BreadcrumbsComponent.new(project, Category)
    end

    # Home > Projects > Sample Project > Categories > Development
    # @label Parent and Nested Record
    def parent_and_nested_record
      project = as_persisted_model(Project.new(id: 1, title: "Sample Project"))
      category = as_persisted_model(Category.new(id: 1, title: "Development", category_type: :scaled))
      render Layout::BreadcrumbsComponent.new(project, category)
    end

    # Home > Projects > Sample Project > Categories > Development > Edit
    # @label Full Nested with String
    def full_nested_with_string
      project = as_persisted_model(Project.new(id: 1, title: "Sample Project"))
      category = as_persisted_model(Category.new(id: 1, title: "Development", category_type: :scaled))
      render Layout::BreadcrumbsComponent.new(project, category, "Edit")
    end

    private

    def as_persisted_model(model)
      model.tap { |m|
        m.define_singleton_method(:persisted?) { true }
      }
    end
  end
end
