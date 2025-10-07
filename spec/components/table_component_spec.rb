# frozen_string_literal: true

require "rails_helper"

RSpec.describe TableComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:projects) { [Project.new(id: 1, title: "Project 1"), Project.new(id: 2, title: "Project 2")] }

  it "renders table with headers" do
    render_inline(TableComponent.new(
      collection: projects,
      row_component: ProjectRowComponent,
      headers: ["Title", "Actions"],
      id: "projects"
    ))

    expect(page).to have_css("table")
    expect(page).to have_css("thead th", text: "Title")
    expect(page).to have_css("thead th", text: "Actions")
  end

  it "renders table body with id" do
    render_inline(TableComponent.new(
      collection: projects,
      row_component: ProjectRowComponent,
      headers: ["Title", "Actions"],
      id: "projects"
    ))

    expect(page).to have_css("tbody#projects")
  end

  it "renders each record using the row component" do
    render_inline(TableComponent.new(
      collection: projects,
      row_component: ProjectRowComponent,
      headers: ["Title", "Actions"],
      id: "projects"
    ))

    expect(page).to have_css("tr.project", count: 2)
  end

  context "with empty collection" do
    it "renders empty message" do
      render_inline(TableComponent.new(
        collection: [],
        row_component: ProjectRowComponent,
        headers: ["Title", "Actions"],
        id: "projects",
        empty_message: "No projects found"
      ))

      expect(page).to have_css("tbody#projects")
      expect(page).to have_css("tr td[colspan='2']", text: "No projects found")
    end
  end

  context "with row options" do
    it "passes options to row components" do
      project = Project.new(id: 1, title: "Project 1")

      render_inline(TableComponent.new(
        collection: [ Category.new(id: 1, title: "Category 1", category_type: "scaled", project: project) ],
        row_component: CategoryRowComponent,
        headers: [ "Title", "Type", "Actions" ],
        id: "categories",
        project: project
      ))

      expect(page).to have_css("tr.category")
    end
  end
end
