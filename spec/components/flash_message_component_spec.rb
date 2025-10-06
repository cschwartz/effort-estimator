require "rails_helper"

RSpec.describe FlashMessageComponent, type: :component do
  include ViewComponent::TestHelpers

  describe "rendering notice flash" do
    it "renders success alert" do
      render_inline(described_class.new(flash_type: "notice", message: "Success!"))
      expect(page).to have_css(".alert.alert-success")
    end

    it "renders the message" do
      render_inline(described_class.new(flash_type: "notice", message: "Success!"))
      expect(page).to have_text("Success!")
    end

    it "renders success icon" do
      render_inline(described_class.new(flash_type: "notice", message: "Success!"))
      expect(page).to have_css("svg.icon-success")
    end

    it "includes notification controller" do
      render_inline(described_class.new(flash_type: "notice", message: "Success!"))
      expect(page).to have_css("[data-controller='notification']")
    end

    it "includes close button" do
      render_inline(described_class.new(flash_type: "notice", message: "Success!"))
      expect(page).to have_css("button[data-action='click->notification#hide']")
    end
  end

  describe "rendering alert flash" do
    it "renders error alert" do
      render_inline(described_class.new(flash_type: "alert", message: "Error!"))
      expect(page).to have_css(".alert.alert-error")
    end

    it "renders the message" do
      render_inline(described_class.new(flash_type: "alert", message: "Error!"))
      expect(page).to have_text("Error!")
    end

    it "renders error icon" do
      render_inline(described_class.new(flash_type: "alert", message: "Error!"))
      expect(page).to have_css("svg.icon-error")
    end
  end

  describe "rendering info flash" do
    it "renders info alert" do
      render_inline(described_class.new(flash_type: "info", message: "Info!"))
      expect(page).to have_css(".alert.alert-info")
    end

    it "renders the message" do
      render_inline(described_class.new(flash_type: "info", message: "Info!"))
      expect(page).to have_text("Info!")
    end

    it "renders info icon" do
      render_inline(described_class.new(flash_type: "info", message: "Info!"))
      expect(page).to have_css("svg.icon-info")
    end
  end
end
