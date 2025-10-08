# frozen_string_literal: true

module Layout
  class FlashMessageComponent < ViewComponent::Base
    def initialize(flash_type:, message:)
      @flash_type = flash_type
      @message = message
    end

    def alert_class
      case @flash_type
      when "notice"
        "alert-success"
      when "alert"
        "alert-error"
      else
        "alert-info"
      end
    end

    def icon_name
      case @flash_type
      when "notice"
        :success
      when "alert"
        :error
      else
        :info
      end
    end
  end
end
