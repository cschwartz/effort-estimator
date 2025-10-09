# frozen_string_literal: true

module Layout
  # @label Index View
  class IndexViewComponentPreview < ViewComponent::Preview
    # @label Projects Index
    def projects_index
      projects = [
        create_project(1, "First Project"),
        create_project(2, "Second Project"),
        create_project(3, "Third Project")
      ]

      render Layout::IndexViewComponent.new(
        resource_class: Project,
        collection: projects,
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        new_path: "/projects/new"
      )
    end

    # @label Categories Index (Nested)
    def categories_index
      project = create_project(1, "Sample Project")
      categories = [
        create_category(1, "Conception", "scaled", project),
        create_category(2, "Implementation", "scaled", project),
        create_category(3, "Hours", "absolute", project)
      ]

      render Layout::IndexViewComponent.new(
        resource_class: Category,
        collection: categories,
        row_component: Table::Rows::CategoryRowComponent,
        headers: [ "Title", "Type", "Actions" ],
        new_path: "/projects/1/categories/new",
        parent_resources: [ project ]
      )
    end

    # @label Empty Collection
    def empty_collection
      render Layout::IndexViewComponent.new(
        resource_class: Project,
        collection: [],
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        new_path: "/projects/new"
      )
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
  end
end
