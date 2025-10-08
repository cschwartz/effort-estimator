# frozen_string_literal: true

module Actions
  class CreateActionComponentPreview < ViewComponent::Preview
    def default
      render Actions::CreateActionComponent.new(href: "#")
    end

    def with_custom_label
      render Actions::CreateActionComponent.new(href: "#", label: "Add Project")
    end

    def with_turbo_frame
      render Actions::CreateActionComponent.new(href: "#", turbo_frame: "new_project")
    end

    def extra_small_size
      render Actions::CreateActionComponent.new(href: "#", size: :xs)
    end

    def with_all_options
      render Actions::CreateActionComponent.new(
        href: "#",
        label: "Add Item",
        turbo_frame: "new_item",
        size: :xs
      )
    end
  end
end
