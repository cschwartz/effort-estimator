# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::PropertyListComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders the details container by default" do
    render_inline(described_class.new)
    expect(page).to have_css(".details.bg-base-100.rounded-lg.p-6")
  end

  it "renders without wrapper when wrapper: false" do
    render_inline(described_class.new(wrapper: false))
    expect(page).not_to have_css(".details")
    expect(page).to have_css("dl.space-y-4")
  end

  it "renders a definition list" do
    render_inline(described_class.new)
    expect(page).to have_css("dl.space-y-4")
  end

  it "renders multiple properties" do
    render_inline(described_class.new) do |component|
      component.with_property_text(label: "Name", value: "Test")
      component.with_property_text(label: "Email", value: "test@example.com")
    end

    expect(page).to have_text("Name")
    expect(page).to have_text("Test")
    expect(page).to have_text("Email")
    expect(page).to have_text("test@example.com")
  end
end
