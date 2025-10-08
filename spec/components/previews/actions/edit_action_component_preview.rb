# frozen_string_literal: true

module Actions
  class EditActionComponentPreview < ViewComponent::Preview
    def default
      render Actions::EditActionComponent.new(href: "#")
    end

    def with_turbo_frame
      render Actions::EditActionComponent.new(href: "#", turbo_frame: "new_project")
    end

    def extra_small_size
      render Actions::EditActionComponent.new(href: "#", size: :xs)
    end

    def table_row_style
      render Actions::EditActionComponent.new(
        href: "#",
        turbo_frame: "new_project",
        size: :xs
      )
    end
  end
end
