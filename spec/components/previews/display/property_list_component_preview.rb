# frozen_string_literal: true

module Display
  class PropertyListComponentPreview < ViewComponent::Preview
    # @label All Property Types
    def all_types; end

    # @label Text Properties Only
    def text_only; end

    # @label Prose Property
    def prose; end

    # @label Badge Property
    def badge; end

    # @label Timestamp Properties
    def timestamps; end

    # @label With Block Content
    def with_block_content; end
  end
end
