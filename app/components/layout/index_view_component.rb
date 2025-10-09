# frozen_string_literal: true

module Layout
  class IndexViewComponent < ViewComponent::Base
    attr_reader :resource_class, :collection, :row_component, :headers, :new_path, :parent_resources

    def initialize(resource_class:, collection:, row_component:, headers:, new_path:, parent_resources: [])
      @resource_class = resource_class
      @collection = collection
      @row_component = row_component
      @headers = headers
      @new_path = new_path
      @parent_resources = parent_resources
    end

    def resource_name
      resource_class.model_name.element
    end

    def resource_name_plural
      resource_class.model_name.plural
    end

    def table_id
      resource_name_plural
    end

    def empty_message
      "No existing #{resource_name_plural}"
    end

    def breadcrumb_parts
      parent_resources + [ resource_class ]
    end

    def row_options
      return {} if parent_resources.empty?

      # For nested resources, pass the parent as an option
      # e.g., { project: @project }
      { parent_resources.first.model_name.element.to_sym => parent_resources.first }
    end
  end
end
