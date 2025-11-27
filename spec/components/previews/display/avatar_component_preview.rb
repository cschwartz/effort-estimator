module Display
  # @label Avatar
  class AvatarComponentPreview < ViewComponent::Preview
    # @label Default (Placeholder)
    def default
      user = User.new(email: "alice@example.com")
      render Display::AvatarComponent.new(
        user: user,
        modifier: :placeholder,
        size: 8
      )
    end
  end
end
