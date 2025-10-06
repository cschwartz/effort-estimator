# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageHeaderComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:project) { Project.create!(title: "Test Project", description: "Test") }

  describe "rendering with a Class" do
    it "renders the pluralized class name" do
      render_inline(described_class.new(Project))

      expect(page).to have_css(".header.prose")
      expect(page).to have_css("h1.title", text: "Projects")
    end

    it "does not render actions container when none provided" do
      render_inline(described_class.new(Project))

      expect(page).not_to have_css(".flex.gap-2.not-prose")
    end
  end

  describe "rendering with a String" do
    it "renders the string as title" do
      render_inline(described_class.new("Custom Title"))

      expect(page).to have_css("h1.title", text: "Custom Title")
    end
  end

  describe "rendering with a persisted record" do
    it "renders the record title" do
      render_inline(described_class.new(project))

      expect(page).to have_css("h1.title", text: project.title)
    end
  end

  describe "rendering with a new record" do
    it "renders 'New' with model name" do
      new_project = Project.new
      render_inline(described_class.new(new_project))

      expect(page).to have_css("h1.title", text: "New Project")
    end
  end

  describe "rendering with actions" do
    it "renders action slots" do
      render_inline(described_class.new(Project)) do |c|
        c.with_action { '<a href="/test" class="btn btn-primary">Test Action</a>'.html_safe }
      end

      expect(page).to have_link("Test Action", href: "/test")
      expect(page).to have_css("a.btn.btn-primary")
    end

    it "renders multiple action slots" do
      render_inline(described_class.new(project)) do |c|
        c.with_action { '<a href="/edit" class="btn">Edit</a>'.html_safe }
        c.with_action { '<button class="btn btn-error">Delete</button>'.html_safe }
      end

      expect(page).to have_link("Edit", href: "/edit")
      expect(page).to have_button("Delete")
    end
  end

  describe "CSS structure" do
    it "renders with correct CSS classes" do
      render_inline(described_class.new(Project))

      expect(page).to have_css(".header.prose.max-w-none")
      expect(page).to have_css(".flex.justify-between.items-baseline")
      expect(page).to have_css("h1.title.mb-0")
    end

    it "renders actions container when actions are provided" do
      render_inline(described_class.new(Project)) do |c|
        c.with_action { CreateActionComponent.new(href: "#").call }
      end

      expect(page).to have_css(".flex.gap-2.not-prose")
    end
  end
end
