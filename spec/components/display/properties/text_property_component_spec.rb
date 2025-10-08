# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::Properties::TextPropertyComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders the label" do
    render_inline(described_class.new(label: "Name", value: "John Doe"))
    expect(page).to have_css("dt", text: "Name")
  end

  it "renders the value" do
    render_inline(described_class.new(label: "Name", value: "John Doe"))
    expect(page).to have_css("dd", text: "John Doe")
  end

  it "renders block content when provided" do
    render_inline(described_class.new(label: "Name")) { "Custom Content" }
    expect(page).to have_css("dd", text: "Custom Content")
  end

  it "applies default css class" do
    render_inline(described_class.new(label: "Name", value: "Test"))
    expect(page).to have_css("dd.text-sm.text-base-content\\/80")
  end

  it "applies custom css class when provided" do
    render_inline(described_class.new(label: "Name", value: "Test", css_class: "custom-class"))
    expect(page).to have_css("dd.custom-class")
  end

  it "wraps content in property-row div" do
    render_inline(described_class.new(label: "Name", value: "Test"))
    expect(page).to have_css(".property-row")
  end
end
