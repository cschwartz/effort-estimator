# frozen_string_literal: true

module Actions
  class DeleteActionComponentPreview < ViewComponent::Preview
    def default
      render Actions::DeleteActionComponent.new(href: "#")
    end

    def with_custom_confirmation
      render Actions::DeleteActionComponent.new(href: "#", confirm: "Really delete this?")
    end

    def without_confirmation
      render Actions::DeleteActionComponent.new(href: "#", confirm: nil)
    end

    def extra_small_size
      render Actions::DeleteActionComponent.new(href: "#", size: :xs)
    end

    def table_row_style
      render Actions::DeleteActionComponent.new(
        href: "#",
        size: :xs
      )
    end
  end
end
