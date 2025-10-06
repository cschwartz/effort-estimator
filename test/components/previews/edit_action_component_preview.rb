class EditActionComponentPreview < ViewComponent::Preview
  def default
    render EditActionComponent.new(href: "#")
  end

  def with_turbo_frame
    render EditActionComponent.new(href: "#", turbo_frame: "new_project")
  end

  def extra_small_size
    render EditActionComponent.new(href: "#", size: :xs)
  end

  def table_row_style
    render EditActionComponent.new(
      href: "#",
      turbo_frame: "new_project",
      size: :xs
    )
  end
end
