# frozen_string_literal: true

require "rails_helper"

RSpec.describe Table::Rows::CategoryRowComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:project) { Project.new(id: 1, title: "Test Project") }
  let(:category) { Category.new(id: 1, title: "Test Category", category_type: "scaled", project: project) }

  it "renders category row with title link" do
    render_inline(Table::Rows::CategoryRowComponent.new(record: category, project: project))

    expect(page).to have_css("tr.category#category_1")
    expect(page).to have_link("Test Category", href: project_category_path(project, category))
  end

  it "renders title in td with title class" do
    render_inline(Table::Rows::CategoryRowComponent.new(record: category, project: project))

    expect(page).to have_css("td.title")
  end

  it "renders type badge with humanized value" do
    render_inline(Table::Rows::CategoryRowComponent.new(record: category, project: project))

    expect(page).to have_css("td.type")
    expect(page).to have_css("span.badge.badge-outline.badge-primary", text: "Scaled")
  end

  it "renders actions column with edit and delete buttons" do
    render_inline(Table::Rows::CategoryRowComponent.new(record: category, project: project))

    expect(page).to have_css("td.actions")
    expect(page).to have_link("Edit", href: edit_project_category_path(project, category))
    expect(page).to have_button("Delete")
  end

  it "renders edit action with xs size and turbo_frame" do
    render_inline(Table::Rows::CategoryRowComponent.new(record: category, project: project))

    expect(page).to have_css("a.btn.btn-primary.btn-xs", text: "Edit")
    expect(page).to have_css("a[data-turbo-frame='new_category']", text: "Edit")
  end

  it "renders delete action with xs size" do
    render_inline(Table::Rows::CategoryRowComponent.new(record: category, project: project))

    expect(page).to have_css("button.btn.btn-error.btn-xs", text: "Delete")
  end

  context "with absolute category type" do
    let(:category) { Category.new(id: 2, title: "Hours", category_type: "absolute", project: project) }

    it "renders humanized type badge" do
      render_inline(Table::Rows::CategoryRowComponent.new(record: category, project: project))

      expect(page).to have_css("span.badge", text: "Absolute")
    end
  end
end
