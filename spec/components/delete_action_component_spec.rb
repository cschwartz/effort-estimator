require "rails_helper"

RSpec.describe DeleteActionComponent, type: :component do
  include ViewComponent::TestHelpers

  describe "rendering" do
    it "renders delete button" do
      render_inline(described_class.new(href: "/delete"))

      expect(page).to have_button("Delete")
      expect(page).to have_css("button.btn.btn-error")
    end

    it "renders with default confirmation" do
      render_inline(described_class.new(href: "/delete"))

      expect(page).to have_css("button[data-confirm='Are you sure?']")
    end

    it "renders with custom confirmation" do
      render_inline(described_class.new(href: "/delete", confirm: "Really delete?"))

      expect(page).to have_css("button[data-confirm='Really delete?']")
    end

    it "renders with default turbo_method delete" do
      render_inline(described_class.new(href: "/delete"))

      expect(page).to have_css("button[data-turbo-method='delete']")
    end

    it "renders without size by default" do
      render_inline(described_class.new(href: "/delete"))

      expect(page).to have_css("button.btn.btn-error")
      expect(page).not_to have_css("button.btn-xs")
      expect(page).not_to have_css("button.btn-sm")
    end

    it "renders with xs size" do
      render_inline(described_class.new(href: "/delete", size: :xs))

      expect(page).to have_css("button.btn.btn-error.btn-xs")
    end

    it "renders with custom CSS classes" do
      render_inline(described_class.new(href: "/delete", class: "custom-class"))

      expect(page).to have_css("button.btn.btn-error.custom-class")
    end
  end
end
