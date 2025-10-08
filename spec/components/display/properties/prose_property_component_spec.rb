# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::Properties::ProsePropertyComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders the label" do
    render_inline(described_class.new(label: "Description", value: "Test content"))
    expect(page).to have_css("dt", text: "Description")
  end

  it "formats value with simple_format" do
    render_inline(described_class.new(label: "Description", value: "Line 1\n\nLine 2"))
    expect(page).to have_css("dd p", count: 2)
  end

  it "renders block content when provided" do
    render_inline(described_class.new(label: "Description")) { "<strong>Bold</strong>".html_safe }
    expect(page).to have_css("dd strong", text: "Bold")
  end

  it "applies default css classes" do
    render_inline(described_class.new(label: "Description", value: "Test"))
    expect(page).to have_css("dd.prose.prose-sm.max-w-none.bg-base-200.rounded.p-3")
  end

  it "applies custom css class when provided" do
    render_inline(described_class.new(label: "Description", value: "Test", css_class: "custom-prose"))
    expect(page).to have_css("dd.custom-prose")
  end
end
