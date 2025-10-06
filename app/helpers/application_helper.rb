module ApplicationHelper
  include Rails.application.routes.url_helpers

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash", partial: "layouts/flash"
  end
end
