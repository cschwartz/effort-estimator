# frozen_string_literal: true

require "rails_helper"

RSpec.describe Table::Columns::ActionsColumnComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  it "renders actions in flex container" do
    actions = [
      Actions::EditActionComponent.new(href: -> { "/edit" }, size: :xs),
      Actions::DeleteActionComponent.new(href: -> { "/delete" }, size: :xs)
    ]

    render_inline(Table::Columns::ActionsColumnComponent.new(actions: actions))

    expect(page).to have_css("div.flex.gap-2")
    expect(page).to have_link("Edit", href: "/edit")
    expect(page).to have_button("Delete")
  end

  it "renders empty container with no actions" do
    render_inline(Table::Columns::ActionsColumnComponent.new(actions: []))

    expect(page).to have_css("div.flex.gap-2")
    expect(page).not_to have_link
    expect(page).not_to have_button
  end
end
