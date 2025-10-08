# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::Properties::BadgePropertyComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders the label" do
    render_inline(described_class.new(label: "Type", value: "scaled"))
    expect(page).to have_css("dt", text: "Type")
  end

  it "renders the value in a badge" do
    render_inline(described_class.new(label: "Type", value: "scaled"))
    expect(page).to have_css("span.badge", text: "Scaled")
  end

  it "humanizes the value" do
    render_inline(described_class.new(label: "Status", value: "work_in_progress"))
    expect(page).to have_css("span.badge", text: "Work in progress")
  end

  it "applies default badge classes" do
    render_inline(described_class.new(label: "Type", value: "scaled"))
    expect(page).to have_css("span.badge.badge-outline.badge-lg")
  end

  it "applies custom variant" do
    render_inline(described_class.new(label: "Type", value: "scaled", variant: :primary))
    expect(page).to have_css("span.badge.badge-primary")
  end

  it "applies custom size" do
    render_inline(described_class.new(label: "Type", value: "scaled", size: :sm))
    expect(page).to have_css("span.badge.badge-sm")
  end

  it "renders block content when provided" do
    render_inline(described_class.new(label: "Type")) { "<span class='custom-badge'>Custom</span>".html_safe }
    expect(page).to have_css(".custom-badge", text: "Custom")
  end

  it "uses parameterized label as dd class by default" do
    render_inline(described_class.new(label: "Category Type", value: "scaled"))
    expect(page).to have_css("dd.category-type")
  end
end
