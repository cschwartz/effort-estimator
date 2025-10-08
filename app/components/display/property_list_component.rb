# frozen_string_literal: true

module Display
  class PropertyListComponent < ViewComponent::Base
    renders_many :properties, types: {
      text: "Display::Properties::TextPropertyComponent",
      prose: "Display::Properties::ProsePropertyComponent",
      badge: "Display::Properties::BadgePropertyComponent",
      timestamp: "Display::Properties::TimestampPropertyComponent"
    }

    def initialize(wrapper: true)
      @wrapper = wrapper
    end

    def wrapper?
      @wrapper
    end
  end
end
