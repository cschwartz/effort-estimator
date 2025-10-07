# frozen_string_literal: true

require "rails_helper"

RSpec.describe BadgeColumnComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  it "renders badge with humanized value" do
    render_inline(BadgeColumnComponent.new(
      header: "Type",
      value: -> { "scaled" }
    ))

    expect(page).to have_css("span.badge.badge-outline.badge-primary", text: "Scaled")
  end

  it "humanizes underscored values" do
    render_inline(BadgeColumnComponent.new(
      header: "Status",
      value: -> { "in_progress" }
    ))

    expect(page).to have_css("span.badge", text: "In progress")
  end
end
