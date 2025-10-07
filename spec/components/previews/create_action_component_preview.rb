class CreateActionComponentPreview < ViewComponent::Preview
  def default
    render CreateActionComponent.new(href: "#")
  end

  def with_custom_label
    render CreateActionComponent.new(href: "#", label: "Add Project")
  end

  def with_turbo_frame
    render CreateActionComponent.new(href: "#", turbo_frame: "new_project")
  end

  def extra_small_size
    render CreateActionComponent.new(href: "#", size: :xs)
  end

  def with_all_options
    render CreateActionComponent.new(
      href: "#",
      label: "Add Item",
      turbo_frame: "new_item",
      size: :xs
    )
  end
end
