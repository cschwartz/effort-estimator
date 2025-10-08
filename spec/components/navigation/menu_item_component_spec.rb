# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::MenuItemComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders the menu item" do
    render_inline(described_class.new(label: "Projects", href: "/projects"))
    expect(page).to have_link("Projects", href: "/projects")
  end

  it "renders within a list item" do
    render_inline(described_class.new(label: "Projects", href: "/projects"))
    expect(page).to have_css("li")
  end

  it "applies active class when active" do
    render_inline(described_class.new(label: "Projects", href: "/projects", active: true))
    expect(page).to have_css("a.active")
  end

  it "does not apply active class when not active" do
    render_inline(described_class.new(label: "Projects", href: "/projects", active: false))
    expect(page).not_to have_css("a.active")
  end

  it "renders subitems" do
    render_inline(described_class.new(label: "Projects", href: "/projects")) do |item|
      item.with_subitem(label: "Overview", href: "/projects/1")
      item.with_subitem(label: "Categories", href: "/projects/1/categories")
    end

    expect(page).to have_link("Overview", href: "/projects/1")
    expect(page).to have_link("Categories", href: "/projects/1/categories")
  end

  it "renders submenu list when subitems exist" do
    render_inline(described_class.new(label: "Projects", href: "/projects")) do |item|
      item.with_subitem(label: "Overview", href: "/projects/1")
    end

    expect(page).to have_css("li > ul")
  end

  it "does not render submenu list when no subitems" do
    render_inline(described_class.new(label: "Projects", href: "/projects"))
    expect(page).not_to have_css("li > ul")
  end
end
