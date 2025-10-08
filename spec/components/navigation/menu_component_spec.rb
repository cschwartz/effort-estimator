# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::MenuComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders the menu container" do
    render_inline(described_class.new)
    expect(page).to have_css("ul.menu.bg-base-200.rounded-box.w-56")
  end

  it "renders the title" do
    render_inline(described_class.new(title: "Main Menu"))
    expect(page).to have_css("h3", text: "Main Menu")
  end

  it "renders default title" do
    render_inline(described_class.new)
    expect(page).to have_css("h3", text: "Menu")
  end

  it "renders menu items" do
    render_inline(described_class.new) do |menu|
      menu.with_item(label: "Home", href: "/")
      menu.with_item(label: "About", href: "/about")
    end

    expect(page).to have_link("Home", href: "/")
    expect(page).to have_link("About", href: "/about")
  end

  it "applies custom css class" do
    render_inline(described_class.new(css_class: "custom-menu"))
    expect(page).to have_css("ul.custom-menu")
  end

  it "renders record menu items" do
    project = Project.new(id: 1, title: "Test Project")
    allow(project).to receive(:persisted?).and_return(true)

    render_inline(described_class.new) do |menu|
      menu.with_record_item(label: "Projects", index_href: "/projects", record: project) do |item|
        item.with_subitem(label: "Overview", href: "/projects/1")
      end
    end

    expect(page).to have_link("Projects", href: "/projects")
    expect(page).to have_link("Overview", href: "/projects/1")
  end
end
