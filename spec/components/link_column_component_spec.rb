# frozen_string_literal: true

require "rails_helper"

RSpec.describe LinkColumnComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  it "renders a link with value from lambda" do
    render_inline(LinkColumnComponent.new(
      header: "Title",
      value: -> { "Test Title" },
      href: -> { "/test/path" }
    ))

    expect(page).to have_link("Test Title", href: "/test/path")
    expect(page).to have_css("a.link.link-hover")
  end

  it "renders with custom turbo_frame" do
    render_inline(LinkColumnComponent.new(
      header: "Title",
      value: -> { "Test" },
      href: -> { "/test" },
      turbo_frame: "custom_frame"
    ))

    expect(page).to have_css("a[data-turbo-frame='custom_frame']")
  end

  it "uses default _top turbo_frame" do
    render_inline(LinkColumnComponent.new(
      header: "Title",
      value: -> { "Test" },
      href: -> { "/test" }
    ))

    expect(page).to have_css("a[data-turbo-frame='_top']")
  end
end
