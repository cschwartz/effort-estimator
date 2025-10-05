# frozen_string_literal: true

require "rails_helper"

RSpec.describe BreadcrumbsComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:project) { Project.create!(title: "Test Project", description: "Test") }
  let(:category) { Category.create!(title: "Test Category", category_type: "scaled", project: project) }

  describe "rendering with a Class" do
    it "renders Home and collection breadcrumbs" do
      render_inline(described_class.new(Project))

      expect(page).to have_css(".breadcrumbs")
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_css("ul li", text: "Projects")
      expect(page).not_to have_link("Projects")
    end
  end

  describe "rendering with a persisted record" do
    it "renders Home, collection, and instance breadcrumbs" do
      render_inline(described_class.new(project))

      expect(page).to have_css(".breadcrumbs")
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Projects", href: projects_path)
      expect(page).to have_css("ul li", text: project.title)
      expect(page).not_to have_link(project.title)
    end
  end

  describe "rendering with a persisted record and String" do
    it "renders Home, collection, instance, and string breadcrumbs" do
      render_inline(described_class.new(project, "Edit"))

      expect(page).to have_css(".breadcrumbs")
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Projects", href: projects_path)
      expect(page).to have_link(project.title, href: project_path(project))
      expect(page).to have_css("ul li", text: "Edit")
      expect(page).not_to have_link("Edit")
    end
  end

  describe "rendering with nested Class resources" do
    it "renders Home, parent, and nested collection breadcrumbs" do
      render_inline(described_class.new(project, Effort))

      expect(page).to have_css(".breadcrumbs")
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Projects", href: projects_path)
      expect(page).to have_link(project.title, href: project_path(project))
      expect(page).to have_css("ul li", text: "Efforts")
      expect(page).not_to have_link("Efforts")
    end
  end

  describe "rendering with parent and nested Class" do
    it "renders Home, parent, and nested collection breadcrumbs" do
      render_inline(described_class.new(project, Category))

      expect(page).to have_css(".breadcrumbs")
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Projects", href: projects_path)
      expect(page).to have_link(project.title, href: project_path(project))
      expect(page).to have_css("ul li", text: "Categories")
      expect(page).not_to have_link("Categories")
    end
  end

  describe "rendering with parent and nested record" do
    it "renders Home, parent, nested collection, and nested instance breadcrumbs" do
      render_inline(described_class.new(project, category))

      expect(page).to have_css(".breadcrumbs")
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Projects", href: projects_path)
      expect(page).to have_link(project.title, href: project_path(project))
      expect(page).to have_link("Categories", href: project_categories_path(project))
      expect(page).to have_css("ul li", text: category.title)
      expect(page).not_to have_link(category.title)
    end
  end

  describe "rendering with parent, nested record, and String" do
    it "renders all breadcrumb levels" do
      render_inline(described_class.new(project, category, "Edit"))

      expect(page).to have_css(".breadcrumbs")
      expect(page).to have_link("Home", href: root_path)
      expect(page).to have_link("Projects", href: projects_path)
      expect(page).to have_link(project.title, href: project_path(project))
      expect(page).to have_link("Categories", href: project_categories_path(project))
      expect(page).to have_link(category.title, href: project_category_path(project, category))
      expect(page).to have_css("ul li", text: "Edit")
      expect(page).not_to have_link("Edit")
    end
  end

  describe "CSS structure" do
    it "renders with correct CSS classes" do
      render_inline(described_class.new(Project))

      expect(page).to have_css(".breadcrumbs.text-sm")
      expect(page).to have_css(".breadcrumbs ul")
      expect(page).to have_css(".breadcrumbs ul li")
    end
  end
end
