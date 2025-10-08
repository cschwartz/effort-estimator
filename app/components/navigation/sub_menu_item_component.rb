# frozen_string_literal: true

module Navigation
  class SubMenuItemComponent < ViewComponent::Base
    def initialize(label:, href:, active: false)
      @label = label
      @href = href
      @active = active
    end
  end
end
