# frozen_string_literal: true

require "rails_helper"

RSpec.describe IconComponent, type: :component do
  include ViewComponent::TestHelpers

  describe "rendering" do
    it "renders an SVG element" do
      render_inline(described_class.new(name: :success))
      expect(page).to have_css("svg")
    end

    it "renders with default size" do
      render_inline(described_class.new(name: :success))
      expect(page).to have_css("svg.h-6.w-6")
    end

    it "renders with custom size" do
      render_inline(described_class.new(name: :success, size: :sm))
      expect(page).to have_css("svg.h-4.w-4")
    end

    it "renders with custom CSS class" do
      render_inline(described_class.new(name: :success, css_class: "text-primary"))
      expect(page).to have_css("svg.text-primary")
    end

    it "renders with default stroke" do
      render_inline(described_class.new(name: :success))
      expect(page).to have_css("svg[stroke='currentColor']")
    end

    it "renders with default fill" do
      render_inline(described_class.new(name: :success))
      expect(page).to have_css("svg[fill='none']")
    end

    it "renders with custom stroke" do
      render_inline(described_class.new(name: :success, stroke: "red"))
      expect(page).to have_css("svg[stroke='red']")
    end

    it "renders with custom fill" do
      render_inline(described_class.new(name: :hashtag, fill: "currentColor"))
      expect(page).to have_css("svg[fill='currentColor']")
    end
  end

  describe "icon types" do
    IconComponent::ICONS.keys.each do |icon_name|
      it "renders #{icon_name} icon" do
        expect { render_inline(described_class.new(name: icon_name)) }.not_to raise_error
        expect(page).to have_css("svg")
      end
    end
  end

  describe "sizes" do
    IconComponent::SIZES.each do |size_name, size_class|
      it "renders #{size_name} size with class #{size_class}" do
        render_inline(described_class.new(name: :success, size: size_name))
        expect(page).to have_css("svg.#{size_class.gsub(' ', '.')}")
      end
    end
  end

  describe "error handling" do
    it "raises error for unknown icon" do
      expect {
        render_inline(described_class.new(name: :nonexistent))
      }.to raise_error(ArgumentError, /Unknown icon/)
    end
  end
end
