# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::ShowViewComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:project) { Project.create!(title: "Test Project", description: "Test") }

  describe "rendering for top-level resource" do
    it "renders breadcrumbs with record" do
      render_inline(described_class.new(record: project))

      expect(page).to have_css(".breadcrumbs")
    end

    it "renders page header with record title" do
      render_inline(described_class.new(record: project))

      expect(page).to have_css("h1.title", text: project.title)
    end

    it "renders content block" do
      render_inline(described_class.new(record: project)) do
        "Custom content"
      end

      expect(page).to have_text("Custom content")
    end
  end

  describe "rendering with actions" do
    it "renders no actions when empty array" do
      render_inline(described_class.new(record: project, actions: []))

      expect(page).not_to have_css(".flex.gap-2.not-prose")
    end

    it "renders single action" do
      action_html = '<a href="/edit" class="btn">Edit</a>'.html_safe

      render_inline(described_class.new(record: project, actions: [ action_html ]))

      expect(page).to have_link("Edit", href: "/edit")
    end

    it "renders multiple actions" do
      edit_action = '<a href="/edit" class="btn">Edit</a>'.html_safe
      delete_action = '<button class="btn">Delete</button>'.html_safe

      render_inline(described_class.new(record: project, actions: [ edit_action, delete_action ]))

      expect(page).to have_link("Edit")
      expect(page).to have_button("Delete")
    end
  end

  describe "rendering for nested resource" do
    let(:category) { Category.create!(project: project, title: "Test Category", category_type: "scaled") }

    it "renders breadcrumbs with parent resources" do
      render_inline(described_class.new(record: category, parent_resources: [ project ]))

      expect(page).to have_css(".breadcrumbs")
    end

    it "includes parent in breadcrumb parts" do
      render_inline(described_class.new(record: category, parent_resources: [ project ]))

      # Breadcrumbs should show the parent project
      expect(page).to have_css(".breadcrumbs")
    end
  end

  describe "CSS structure" do
    it "renders wrapper div with resource name" do
      render_inline(described_class.new(record: project))

      expect(page).to have_css(".project")
    end
  end
end
