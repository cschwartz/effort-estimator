# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::Properties::TimestampPropertyComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:timestamp) { Time.zone.parse("2024-10-07 14:30:00") }

  it "renders the label" do
    render_inline(described_class.new(label: "Created", value: timestamp))
    expect(page).to have_css("dt", text: "Created")
  end

  it "formats timestamp with long format by default" do
    render_inline(described_class.new(label: "Created", value: timestamp))
    expect(page).to have_css("dd", text: "October 07, 2024 at 02:30 PM")
  end

  it "formats timestamp with short format" do
    render_inline(described_class.new(label: "Created", value: timestamp, format: :short))
    expect(page).to have_css("dd", text: "Oct 07, 2024")
  end

  it "formats timestamp with date format" do
    render_inline(described_class.new(label: "Created", value: timestamp, format: :date))
    expect(page).to have_css("dd", text: "October 07, 2024")
  end

  it "formats timestamp with time format" do
    render_inline(described_class.new(label: "Created", value: timestamp, format: :time))
    expect(page).to have_css("dd", text: "02:30 PM")
  end

  it "applies default css classes" do
    render_inline(described_class.new(label: "Created", value: timestamp))
    expect(page).to have_css("dd.text-sm.text-base-content\\/80")
  end

  it "applies custom css class when provided" do
    render_inline(described_class.new(label: "Created", value: timestamp, css_class: "custom-timestamp"))
    expect(page).to have_css("dd.custom-timestamp")
  end
end
