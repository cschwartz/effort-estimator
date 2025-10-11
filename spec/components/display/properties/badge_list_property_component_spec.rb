# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::Properties::BadgeListPropertyComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders the label" do
    render_inline(described_class.new(label: "Values", values: [ 1, 2, 3 ]))
    expect(page).to have_css("dt", text: "Values")
  end

  it "renders multiple values as badges" do
    render_inline(described_class.new(label: "Values", values: [ 1, 2, 3 ]))
    expect(page).to have_css("span.badge", text: "1")
    expect(page).to have_css("span.badge", text: "2")
    expect(page).to have_css("span.badge", text: "3")
  end

  it "applies default badge classes to all badges" do
    render_inline(described_class.new(label: "Values", values: [ 1, 2 ]))
    expect(page).to have_css("span.badge.badge-outline.badge-lg", count: 2)
  end

  it "applies custom variant to all badges" do
    render_inline(described_class.new(label: "Values", values: [ 1, 2 ], variant: :primary))
    expect(page).to have_css("span.badge.badge-primary", count: 2)
  end

  it "applies custom size to all badges" do
    render_inline(described_class.new(label: "Values", values: [ 1, 2 ], size: :sm))
    expect(page).to have_css("span.badge.badge-sm", count: 2)
  end

  it "renders block content when provided" do
    render_inline(described_class.new(label: "Values", values: [ 1 ])) { "<span class='custom-content'>Custom</span>".html_safe }
    expect(page).to have_css(".custom-content", text: "Custom")
  end

  it "uses parameterized label as dd class by default" do
    render_inline(described_class.new(label: "Option Values", values: [ 1 ]))
    expect(page).to have_css("dd.option-values")
  end

  it "uses custom css_class when provided" do
    render_inline(described_class.new(label: "Values", values: [ 1 ], css_class: "custom-class"))
    expect(page).to have_css("dd.custom-class")
  end

  it "wraps badges in a flex container" do
    render_inline(described_class.new(label: "Values", values: [ 1, 2 ]))
    expect(page).to have_css("div.flex.flex-wrap.gap-2")
  end

  describe "conditional rendering" do
    it "does not render when values array is empty" do
      component = described_class.new(label: "Values", values: [])
      expect(component.render?).to be false
    end

    it "does render when values array has items" do
      component = described_class.new(label: "Values", values: [ 1 ])
      expect(component.render?).to be true
    end
  end
end
