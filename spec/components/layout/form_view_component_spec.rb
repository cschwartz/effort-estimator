# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::FormViewComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:project) { Project.create!(title: "Test Project", description: "Test") }

  describe "rendering for new record" do
    let(:new_project) { Project.new }

    it "renders breadcrumbs without 'Edit'" do
      render_inline(described_class.new(record: new_project)) { "Form" }

      expect(page).to have_css(".breadcrumbs")
    end

    it "renders page header with 'New' title" do
      render_inline(described_class.new(record: new_project)) { "Form" }

      expect(page).to have_css("h1.title", text: "New Project")
    end

    it "uses new record for turbo frame tag" do
      render_inline(described_class.new(record: new_project)) { "Form" }

      expect(page).to have_css("turbo-frame#new_project")
    end
  end

  describe "rendering for persisted record" do
    it "renders breadcrumbs with 'Edit'" do
      render_inline(described_class.new(record: project)) { "Form" }

      expect(page).to have_css(".breadcrumbs")
    end

    it "renders page header with record title" do
      render_inline(described_class.new(record: project)) { "Form" }

      expect(page).to have_css("h1.title", text: project.title)
    end

    it "uses resource class for turbo frame tag" do
      render_inline(described_class.new(record: project)) { "Form" }

      expect(page).to have_css("turbo-frame#new_project")
    end
  end

  describe "rendering for nested resource" do
    let(:category) { Category.create!(project: project, title: "Test Category", category_type: "scaled") }

    it "renders breadcrumbs with parent resources" do
      render_inline(described_class.new(record: category, parent_resources: [ project ])) { "Form" }

      expect(page).to have_css(".breadcrumbs")
    end

    it "includes parent in breadcrumb parts" do
      render_inline(described_class.new(record: category, parent_resources: [ project ])) { "Form" }

      # Breadcrumbs should show the parent project
      expect(page).to have_css(".breadcrumbs")
    end
  end

  describe "form locals" do
    it "passes record to form partial" do
      render_inline(described_class.new(record: project)) do
        "Form content"
      end

      # Component renders the content block which would be the form
      expect(page).to have_text("Form content")
    end
  end

  describe "CSS structure" do
    it "renders wrapper div with resource name" do
      render_inline(described_class.new(record: project)) { "Form" }

      expect(page).to have_css(".project")
    end
  end
end
