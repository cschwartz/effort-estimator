# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::IndexViewComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:project) { Project.create!(title: "Test Project", description: "Test") }
  let(:projects) { [ project ] }

  describe "rendering for top-level resource" do
    it "renders breadcrumbs with resource class" do
      render_inline(described_class.new(
        resource_class: Project,
        collection: projects,
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        new_path: new_project_path
      ))

      expect(page).to have_css(".breadcrumbs")
    end

    it "renders page header with resource class" do
      render_inline(described_class.new(
        resource_class: Project,
        collection: projects,
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        new_path: new_project_path
      ))

      expect(page).to have_css("h1.title", text: "Projects")
    end

    it "renders create action with correct path" do
      render_inline(described_class.new(
        resource_class: Project,
        collection: projects,
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        new_path: new_project_path
      ))

      expect(page).to have_link("Create", href: new_project_path)
    end

    it "renders table component" do
      render_inline(described_class.new(
        resource_class: Project,
        collection: projects,
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        new_path: new_project_path
      ))

      expect(page).to have_css("table")
      expect(page).to have_css("#projects")
    end
  end

  describe "rendering for nested resource" do
    let(:category) { Category.create!(project: project, title: "Test Category", category_type: "scaled") }
    let(:categories) { [ category ] }

    it "renders breadcrumbs with parent resources" do
      render_inline(described_class.new(
        resource_class: Category,
        collection: categories,
        row_component: Table::Rows::CategoryRowComponent,
        headers: [ "Title", "Type", "Actions" ],
        new_path: new_project_category_path(project),
        parent_resources: [ project ]
      ))

      expect(page).to have_css(".breadcrumbs")
    end

    it "renders create action with correct nested path" do
      render_inline(described_class.new(
        resource_class: Category,
        collection: categories,
        row_component: Table::Rows::CategoryRowComponent,
        headers: [ "Title", "Type", "Actions" ],
        new_path: new_project_category_path(project),
        parent_resources: [ project ]
      ))

      expect(page).to have_link("Create", href: new_project_category_path(project))
    end
  end

  describe "CSS structure" do
    it "renders wrapper div with pluralized resource name" do
      render_inline(described_class.new(
        resource_class: Project,
        collection: projects,
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        new_path: new_project_path
      ))

      expect(page).to have_css(".projects")
    end

    it "renders list container" do
      render_inline(described_class.new(
        resource_class: Project,
        collection: projects,
        row_component: Table::Rows::ProjectRowComponent,
        headers: [ "Title", "Actions" ],
        new_path: new_project_path
      ))

      expect(page).to have_css(".list")
    end
  end
end
