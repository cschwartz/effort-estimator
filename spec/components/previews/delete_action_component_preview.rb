class DeleteActionComponentPreview < ViewComponent::Preview
  def default
    render DeleteActionComponent.new(href: "#")
  end

  def with_custom_confirmation
    render DeleteActionComponent.new(href: "#", confirm: "Really delete this?")
  end

  def without_confirmation
    render DeleteActionComponent.new(href: "#", confirm: nil)
  end

  def extra_small_size
    render DeleteActionComponent.new(href: "#", size: :xs)
  end

  def table_row_style
    render DeleteActionComponent.new(
      href: "#",
      size: :xs
    )
  end
end
