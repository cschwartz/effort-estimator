# frozen_string_literal: true

module Display
  class AvatarComponent < ViewComponent::Base
    def initialize(user:, modifier: nil, size: 8, **options)
      @user = user
      @options = options
    end

    private

    def display_text
      @user.email[0..1].upcase
    end

    def avatar_classes
      classes = [ "avatar", "avatar-placeholder" ]
      classes << @options[:class] if @options[:class]
      classes.compact.join(" ")
    end

    def inner_classes
      classes = [ "bg-neutral", "text-neutral-content", "rounded-full" ]
      classes << "w-8"
      classes.join(" ")
    end

    def text_size_class
      "text-xs"
    end
  end
end
