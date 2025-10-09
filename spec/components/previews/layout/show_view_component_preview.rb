# frozen_string_literal: true

module Layout
  # @label Show View
  class ShowViewComponentPreview < ViewComponent::Preview
    # @label Project Show
    def project_show
      project = create_project(1, "Sample Project")
      edit_action = view_context.render(Actions::EditActionComponent.new(
        href: "/projects/1/edit",
        turbo_frame: "new_project"
      ))
      delete_action = view_context.render(Actions::DeleteActionComponent.new(
        href: "/projects/1"
      ))

      render Layout::ShowViewComponent.new(
        record: project,
        actions: [ edit_action, delete_action ]
      ) do
        view_context.render(Display::PropertyListComponent.new) do |list|
          list.with_property_prose(
            label: "Description",
            value: "This is a sample project description with multiple paragraphs.\n\nIt demonstrates how the prose property displays longer text content.",
            css_class: "description prose prose-sm max-w-none bg-base-200 rounded p-3"
          )
        end
      end
    end

    # @label Category Show (Nested)
    def category_show
      project = create_project(1, "Sample Project")
      category = create_category(1, "Conception", "scaled", project)
      edit_action = view_context.render(Actions::EditActionComponent.new(
        href: "/projects/1/categories/1/edit",
        turbo_frame: "new_category"
      ))
      delete_action = view_context.render(Actions::DeleteActionComponent.new(
        href: "/projects/1/categories/1"
      ))

      render Layout::ShowViewComponent.new(
        record: category,
        parent_resources: [ project ],
        actions: [ edit_action, delete_action ]
      ) do
        view_context.render(Display::PropertyListComponent.new) do |list|
          list.with_property_badge(label: "Type", value: "scaled", css_class: "category-type")
          list.with_property_timestamp(label: "Created", value: Time.current - 5.days)
          list.with_property_timestamp(label: "Last Updated", value: Time.current)
        end
      end
    end

    # @label Parameter Show (No Actions)
    def parameter_show
      project = create_project(1, "Sample Project")
      parameter = create_parameter(1, "Team Size", project)

      render Layout::ShowViewComponent.new(
        record: parameter,
        parent_resources: [ project ]
      ) do
        view_context.render(Display::PropertyListComponent.new) do |list|
          list.with_property_text(label: "Title", value: "Team Size")
          list.with_property_timestamp(label: "Created", value: Time.current - 3.days)
          list.with_property_timestamp(label: "Updated", value: Time.current)
        end
      end
    end

    private

    def create_project(id, title)
      project = Project.new(id: id, title: title, description: "Description for #{title}")
      project.define_singleton_method(:persisted?) { true }
      project.define_singleton_method(:created_at) { Time.current }
      project.define_singleton_method(:updated_at) { Time.current }
      project
    end

    def create_category(id, title, type, project)
      category = Category.new(id: id, title: title, category_type: type, project: project)
      category.define_singleton_method(:persisted?) { true }
      category.define_singleton_method(:created_at) { Time.current }
      category.define_singleton_method(:updated_at) { Time.current }
      category
    end

    def create_parameter(id, title, project)
      parameter = Parameter.new(id: id, title: title, project: project)
      parameter.define_singleton_method(:persisted?) { true }
      parameter.define_singleton_method(:created_at) { Time.current }
      parameter.define_singleton_method(:updated_at) { Time.current }
      parameter
    end
  end
end
