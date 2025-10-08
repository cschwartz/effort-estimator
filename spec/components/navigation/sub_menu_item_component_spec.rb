# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::SubMenuItemComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders the submenu item link" do
    render_inline(described_class.new(label: "Overview", href: "/projects/1"))
    expect(page).to have_link("Overview", href: "/projects/1")
  end

  it "applies active class when active" do
    render_inline(described_class.new(label: "Overview", href: "/projects/1", active: true))
    expect(page).to have_css("a.active", text: "Overview")
  end

  it "does not apply active class when not active" do
    render_inline(described_class.new(label: "Overview", href: "/projects/1", active: false))
    expect(page).not_to have_css("a.active")
  end
end
