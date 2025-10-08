# frozen_string_literal: true

module Table
  class TableComponentPreview < ViewComponent::Preview
    # @label Projects Table
    def projects
      projects = [
        Project.new(id: 1, title: "Project Alpha"),
        Project.new(id: 2, title: "Project Beta"),
        Project.new(id: 3, title: "Project Gamma")
      ]

      render Table::TableComponent.new(
        collection: projects,
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        id: "projects"
      )
    end

    # @label Categories Table
    def categories
      project = Project.new(id: 1, title: "Test Project")
      categories = [
        Category.new(id: 1, title: "Conception", category_type: "scaled", project: project),
        Category.new(id: 2, title: "Implementation", category_type: "scaled", project: project),
        Category.new(id: 3, title: "Hours", category_type: "absolute", project: project)
      ]

      render Table::TableComponent.new(
        collection: categories,
        row_component: Table::Rows::CategoryRowComponent,
        headers: [ "Title", "Type", "Actions" ],
        id: "categories",
        project: project
      )
    end

    # @label Empty Table
    def empty
      render Table::TableComponent.new(
        collection: [],
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        id: "projects",
        empty_message: "No projects found"
      )
    end
  end
end
