# frozen_string_literal: true

require "rails_helper"

RSpec.describe Forms::FormErrorsComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:project) { Project.new }

  describe "rendering with errors" do
    before do
      project.errors.add(:title, "can't be blank")
    end

    it "renders the error alert" do
      render_inline(described_class.new(project))

      expect(page).to have_css(".alert.alert-error")
      expect(page).to have_css('[role="alert"]')
    end

    it "renders the error icon" do
      render_inline(described_class.new(project))

      expect(page).to have_css("svg")
    end

    it "renders the validation error heading" do
      render_inline(described_class.new(project))

      expect(page).to have_css("h3", text: "Validation Error")
    end

    it "renders the error message" do
      render_inline(described_class.new(project))

      expect(page).to have_text("Title can't be blank")
    end

    it "renders the capitalized error message" do
      render_inline(described_class.new(project))

      # The error message is capitalized by .capitalize
      expect(page).to have_css("div.text-xs", text: /^[A-Z]/)
    end
  end

  describe "rendering with multiple errors" do
    before do
      project.errors.add(:title, "can't be blank")
      project.errors.add(:description, "is too short")
    end

    it "renders all errors in a sentence" do
      render_inline(described_class.new(project))

      expect(page).to have_text("can't be blank")
      expect(page).to have_text("is too short")
    end
  end

  describe "rendering without errors" do
    it "does not render anything" do
      render_inline(described_class.new(project))

      expect(page).not_to have_css(".alert")
    end
  end

  describe "CSS structure" do
    before do
      project.errors.add(:title, "can't be blank")
    end

    it "renders with correct CSS classes" do
      render_inline(described_class.new(project))

      expect(page).to have_css(".alert.alert-error.mb-4")
      expect(page).to have_css("h3.font-bold")
      expect(page).to have_css("div.text-xs")
    end
  end
end
