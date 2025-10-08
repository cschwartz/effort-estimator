# frozen_string_literal: true

module Navigation
  class MenuComponent < ViewComponent::Base
    renders_many :items, types: {
      item: { renders: "Navigation::MenuItemComponent", as: :item },
      record_item: { renders: "Navigation::RecordMenuItemComponent", as: :record_item }
    }

    def initialize(title: "Menu", css_class: nil)
      @title = title
      @css_class = css_class
    end

    def menu_class
      @css_class || "menu bg-base-200 rounded-box w-56"
    end
  end
end
