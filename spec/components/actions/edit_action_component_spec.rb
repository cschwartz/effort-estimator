require "rails_helper"

RSpec.describe Actions::EditActionComponent, type: :component do
  include ViewComponent::TestHelpers

  describe "rendering" do
    it "renders edit link" do
      render_inline(described_class.new(href: "/edit"))

      expect(page).to have_link("Edit", href: "/edit")
      expect(page).to have_css("a.btn.btn-primary")
    end

    it "renders with turbo_frame" do
      render_inline(described_class.new(href: "/edit", turbo_frame: "my_frame"))

      expect(page).to have_css("a[data-turbo-frame='my_frame']")
    end

    it "renders without size by default" do
      render_inline(described_class.new(href: "/edit"))

      expect(page).to have_css("a.btn.btn-primary")
      expect(page).not_to have_css("a.btn-xs")
      expect(page).not_to have_css("a.btn-sm")
    end

    it "renders with xs size" do
      render_inline(described_class.new(href: "/edit", size: :xs))

      expect(page).to have_css("a.btn.btn-primary.btn-xs")
    end

    it "renders with custom CSS classes" do
      render_inline(described_class.new(href: "/edit", class: "custom-class"))

      expect(page).to have_css("a.btn.btn-primary.custom-class")
    end
  end
end
