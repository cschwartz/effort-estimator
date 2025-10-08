# frozen_string_literal: true

module Navigation
  class MenuItemComponent < ViewComponent::Base
    renders_many :subitems, "Navigation::SubMenuItemComponent"

    def initialize(label:, href:, active: false)
      @label = label
      @href = href
      @active = active
    end

    def has_subitems?
      subitems.any?
    end
  end
end
