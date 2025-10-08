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

    def icon_svg
      case @flash_type
      when "notice"
        success_icon
      when "alert"
        error_icon
      else
        info_icon
      end
    end

    private

    def success_icon
      <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current icon-success" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      SVG
    end

    def error_icon
      <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current icon-error" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      SVG
    end

    def info_icon
      <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="h-6 w-6 shrink-0 stroke-current icon-info">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
      SVG
    end
  end
end
