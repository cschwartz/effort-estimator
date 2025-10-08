# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::RecordMenuItemComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:project) do
    p = Project.new(id: 1, title: "Test Project")
    allow(p).to receive(:persisted?).and_return(true)
    p
  end
  let(:new_project) { Project.new }

  it "renders the menu item with index link" do
    render_inline(described_class.new(label: "Projects", index_href: "/projects"))
    expect(page).to have_link("Projects", href: "/projects")
  end

  it "renders within a list item" do
    render_inline(described_class.new(label: "Projects", index_href: "/projects"))
    expect(page).to have_css("li")
  end

  it "applies active class when active" do
    render_inline(described_class.new(label: "Projects", index_href: "/projects", active: true))
    expect(page).to have_css("a.active")
  end

  context "when record is persisted" do
    it "renders subitems" do
      render_inline(described_class.new(label: "Projects", index_href: "/projects", record: project)) do |item|
        item.with_subitem(label: "Overview", href: "/projects/1")
        item.with_subitem(label: "Categories", href: "/projects/1/categories")
      end

      expect(page).to have_link("Overview", href: "/projects/1")
      expect(page).to have_link("Categories", href: "/projects/1/categories")
    end

    it "renders submenu list" do
      render_inline(described_class.new(label: "Projects", index_href: "/projects", record: project)) do |item|
        item.with_subitem(label: "Overview", href: "/projects/1")
      end

      expect(page).to have_css("li > ul")
    end
  end

  context "when record is nil" do
    it "does not render subitems" do
      render_inline(described_class.new(label: "Projects", index_href: "/projects", record: nil)) do |item|
        item.with_subitem(label: "Overview", href: "/projects/1")
      end

      expect(page).not_to have_link("Overview")
    end

    it "does not render submenu list" do
      render_inline(described_class.new(label: "Projects", index_href: "/projects", record: nil)) do |item|
        item.with_subitem(label: "Overview", href: "/projects/1")
      end

      expect(page).not_to have_css("li > ul")
    end
  end

  context "when record is not persisted" do
    it "does not render subitems" do
      render_inline(described_class.new(label: "Projects", index_href: "/projects", record: new_project)) do |item|
        item.with_subitem(label: "Overview", href: "/projects/1")
      end

      expect(page).not_to have_link("Overview")
    end

    it "does not render submenu list" do
      render_inline(described_class.new(label: "Projects", index_href: "/projects", record: new_project)) do |item|
        item.with_subitem(label: "Overview", href: "/projects/1")
      end

      expect(page).not_to have_css("li > ul")
    end
  end

  context "when no subitems defined" do
    it "does not render submenu list even with persisted record" do
      render_inline(described_class.new(label: "Projects", index_href: "/projects", record: project))
      expect(page).not_to have_css("li > ul")
    end
  end
end
