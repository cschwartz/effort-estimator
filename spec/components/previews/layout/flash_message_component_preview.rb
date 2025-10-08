# frozen_string_literal: true

module Layout
  class FlashMessageComponentPreview < ViewComponent::Preview
    def notice
      render Layout::FlashMessageComponent.new(flash_type: "notice", message: "Project was successfully created.")
    end

    def alert
      render Layout::FlashMessageComponent.new(flash_type: "alert", message: "There was an error processing your request.")
    end

    def info
      render Layout::FlashMessageComponent.new(flash_type: "info", message: "Your session will expire in 5 minutes.")
    end
  end
end
