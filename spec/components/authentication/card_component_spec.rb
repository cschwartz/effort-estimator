require "rails_helper"

RSpec.describe Authentication::CardComponent, type: :component do
  include ViewComponent::TestHelpers

  describe "rendering with title" do
    it "renders the title" do
      render_inline(described_class.new(title: "Log in")) do
        "Form content"
      end

      expect(page).to have_text("Log in")
    end

    it "renders the content block" do
      render_inline(described_class.new(title: "Reset Password")) do
        "Password reset form"
      end

      expect(page).to have_text("Password reset form")
    end
  end

  describe "rendering with subtitle" do
    it "renders the subtitle when provided" do
      render_inline(described_class.new(title: "Welcome", subtitle: "Please sign in to continue")) do
        "Content"
      end

      expect(page).to have_text("Please sign in to continue")
    end
  end

  describe "rendering with links" do
    it "renders links in the footer" do
      render_inline(described_class.new(title: "Log in")) do |component|
        component.with_link { '<a href="#">Sign up</a>'.html_safe }
        component.with_link { '<a href="#">Forgot password?</a>'.html_safe }
        "Form content"
      end

      expect(page).to have_link("Sign up")
      expect(page).to have_link("Forgot password?")
    end
  end
end
