module ApplicationHelper
  include Rails.application.routes.url_helpers

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash", partial: "layouts/flash"
  end

  def breadcrumbs(*parts)
    content_tag :div, class: "breadcrumbs text-sm" do
      content_tag :ul do
        breadcrumb_items(*parts).join.html_safe
      end
    end
  end

  def page_header(item, actions: [])
    title = case item
    when Class
      item.name.pluralize
    when ActiveRecord::Base
      item.persisted? ? item.title : "New #{item.model_name.human}"
    when String
      item
    end

    content_tag :div, class: "header prose max-w-none" do
      content_tag :div, class: "flex justify-between items-baseline" do
        concat content_tag(:h1, title, class: "title mb-0")
        concat content_tag(:div, actions.map { |action| render_action(action) }.join.html_safe, class: "flex gap-2 not-prose")
      end
    end
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

  private

  def render_action(action)
    label = action[:label]
    link = action[:link]
    type = action[:type] || :link_to
    color = action[:color] || "btn-primary"
    size = action[:size] || "btn-md"
    options = action[:options] || {}

    css_classes = "btn #{color} #{size}"

    case type
    when :button_to
      method = options[:method] || :delete
      data = options[:data] || {}
      form_options = options[:form] || {}

      button_to label, link,
        method: method,
        data: data,
        class: css_classes,
        form: form_options
    else
      existing_classes = options[:class] || ""
      final_classes = [ css_classes, existing_classes ].join(" ").strip
      link_options = options.merge(class: final_classes)
      link_to label, link, link_options
    end
  end

  private

  def breadcrumb_items(*parts)
    items = []
    parents = []

    parts.each_with_index do |part, index|
      is_last = (index == parts.length - 1)

      case part
      when Class
        collection_name = part.name.pluralize

        if parents.empty?
          collection_path = url_for(part)
        else
          collection_path = url_for([ *parents, part.model_name.collection.to_sym ])
        end

        items << breadcrumb_link_or_text(collection_name, collection_path, is_last)
      when ActiveRecord::Base
        collection_name = part.class.model_name.collection.humanize

        if parents.empty?
          collection_path = url_for(controller: part.class.model_name.collection, action: :index)
        else
          collection_path = url_for([ *parents, part.class.model_name.collection.to_sym ])
        end

        unless is_last
          items << breadcrumb_link_or_text(collection_name, collection_path, false)
        end

        if part.persisted?
          instance_path = url_for([ *parents, part ])
          items << breadcrumb_link_or_text(part.title, instance_path, is_last)
          parents << part
        end

      when String
        items << content_tag(:li, part)

      end
    end

    items
  end

  def breadcrumb_link_or_text(label, path, is_current)
    if is_current || current_page?(path)
      content_tag(:li, label)
    else
      content_tag(:li, link_to(label, path))
    end
  end
end
