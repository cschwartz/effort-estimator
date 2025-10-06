module ApplicationHelper
  include Rails.application.routes.url_helpers

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash", partial: "layouts/flash"
  end

  def form_errors(model)
    return unless model.errors.any?

    content_tag :div, role: "alert", class: "alert alert-error mb-4" do
      svg = tag.svg(xmlns: "http://www.w3.org/2000/svg", class: "h-6 w-6 shrink-0 stroke-current", fill: "none", viewBox: "0 0 24 24") do
        tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z")
      end

      error_content = content_tag(:div) do
        concat content_tag(:h3, "Validation Error", class: "font-bold")
        concat content_tag(:div, model.errors.full_messages.to_sentence.capitalize, class: "text-xs")
      end

      svg + error_content
    end
  end
end
