# frozen_string_literal: true

require "rails_helper"

RSpec.describe Table::Columns::TextColumnComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  it "renders text from lambda" do
    render_inline(Table::Columns::TextColumnComponent.new(
      header: "Description",
      value: -> { "Test description" }
    ))

    expect(page).to have_text("Test description")
  end
end
