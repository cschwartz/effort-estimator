# frozen_string_literal: true

require "rails_helper"

RSpec.describe Table::Rows::ProjectRowComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:project) { Project.new(id: 1, title: "Test Project") }

  it "renders project row with title link" do
    render_inline(Table::Rows::ProjectRowComponent.new(record: project))

    expect(page).to have_css("tr.project#project_1")
    expect(page).to have_link("Test Project", href: project_path(project))
  end

  it "renders title in td with title class" do
    render_inline(Table::Rows::ProjectRowComponent.new(record: project))

    expect(page).to have_css("td.title")
  end

  it "renders actions column with edit and delete buttons" do
    render_inline(Table::Rows::ProjectRowComponent.new(record: project))

    expect(page).to have_css("td.actions")
    expect(page).to have_link("Edit", href: edit_project_path(project))
    expect(page).to have_button("Delete")
  end

  it "renders edit action with xs size and turbo_frame" do
    render_inline(Table::Rows::ProjectRowComponent.new(record: project))

    expect(page).to have_css("a.btn.btn-primary.btn-xs", text: "Edit")
    expect(page).to have_css("a[data-turbo-frame='new_project']", text: "Edit")
  end

  it "renders delete action with xs size" do
    render_inline(Table::Rows::ProjectRowComponent.new(record: project))

    expect(page).to have_css("button.btn.btn-error.btn-xs", text: "Delete")
  end
end
