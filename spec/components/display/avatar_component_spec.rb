require "rails_helper"

RSpec.describe Display::AvatarComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:user) { User.new(email: "alice@example.com") }

  describe "rendering" do
    it "displays user initials derived from email" do
      render_inline(described_class.new(user: user))

      expect(page).to have_text("AL")
    end

    it "uppercases the initials" do
      user_lowercase = User.new(email: "john.doe@example.com")
      render_inline(described_class.new(user: user_lowercase))

      expect(page).to have_text("JO")
    end

    it "uses first two characters of email" do
      user_short = User.new(email: "z@example.com")
      render_inline(described_class.new(user: user_short))

      expect(page).to have_text("Z@")
    end
  end
end
