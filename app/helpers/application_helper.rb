module ApplicationHelper
  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash", partial: "layouts/flash"
  end

  def breadcrumbs(entity = nil, current_page = nil)
    content_tag :div, class: "breadcrumbs text-sm" do
      content_tag :ul do
        breadcrumb_items(entity, current_page).join.html_safe
      end
    end
  end

  def page_header(title, actions: [])
    content_tag :div, class: "header prose max-w-none" do
      content_tag :div, class: "flex justify-between items-baseline" do
        concat content_tag(:h1, title, class: "title mb-0")
        unless actions.empty?
          concat content_tag(:div, actions.map { |action| render_action(action) }.join.html_safe, class: "flex gap-2 not-prose")
        end
      end
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
      final_classes = [css_classes, existing_classes].join(" ").strip
      link_options = options.merge(class: final_classes)
      link_to label, link, link_options
    end
  end

  private

  def breadcrumb_items(entity, current_page)
    items = []
    
    if entity
      collection, collection_path = from_entity entity
    
      unless current_page?(collection_path)
        items << content_tag(:li, link_to(collection.humanize, collection_path))
      else
        items << content_tag(:li, collection.humanize)
      end
      
      if !(entity.is_a? Class) and entity.persisted?
        entity_path = url_for(entity)
        if current_page && !current_page?(entity_path)
          items << content_tag(:li, link_to(entity.title, entity_path))
        else
          items << content_tag(:li, entity.title)
        end
      end
    end
    
    if current_page
      items << content_tag(:li, current_page)
    end
    
    items
  end

  def from_entity(entity)
    if entity.is_a? Class
        collection = entity.name.pluralize
        collection_path = url_for(Project)

        return collection, collection_path
    else
        collection = entity.class.model_name.collection
        collection_path = url_for(controller: collection, action: :index)

        return collection, collection_path
    end
  end
end
