# frozen_string_literal: true

module Navigation
  class MenuComponentPreview < ViewComponent::Preview
    # @label Simple Menu
    def simple; end

    # @label Menu with Subitems
    def with_subitems; end

    # @label Menu with Active Items
    def with_active_items; end

    # @label Multiple Top-Level Items
    def multiple_items; end

    # @label Record Menu Item (with record)
    def record_item_with_record; end

    # @label Record Menu Item (without record)
    def record_item_without_record; end
  end
end
