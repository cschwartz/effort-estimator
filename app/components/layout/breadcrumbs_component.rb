# frozen_string_literal: true

module Layout
  class BreadcrumbsComponent < ViewComponent::Base
    # include Rails.application.routes.url_helpers

    def initialize(*parts, url_helpers: Rails.application.routes.url_helpers, singular_resources: [])
      @parts = parts
      @url_helpers = url_helpers
      @singular_resources = Array(singular_resources).map(&:name)
    end

    def items
      @items ||= build_breadcrumb_items
    end

    private

    def singular_resource?(model_class, parents)
      # Check if this model class is in the singular_resources list
      @singular_resources.include?(model_class.model_name.name)
    end

    def build_breadcrumb_items
      items = [ { label: "Home", path: :root, is_current: false } ]
      parents = []

      @parts.each_with_index do |part, index|
        is_last = (index == @parts.length - 1)

        case part
        when Class
          collection_name = part.name.pluralize

          if parents.empty?
            collection_path = part
          else
            collection_path = [ *parents, part.model_name.collection.to_sym ]
          end

          items << { label: collection_name, path: collection_path, is_current: is_last }
        when ActiveRecord::Base
          collection_name = part.class.model_name.collection.humanize
          is_singular_resource = singular_resource?(part.class, parents)

          if parents.empty?
            collection_path = part.class
          else
            if is_singular_resource
              collection_path = [ *parents, part.class.model_name.element.to_sym ]
            else
              collection_path = [ *parents, part.class.model_name.collection.to_sym ]
            end
          end

          if part.persisted?
            # For singular resources, skip the collection link and only show instance
            if is_singular_resource
              instance_path = [ *parents, part ]
              items << { label: part.title, path: instance_path, is_current: is_last }
            else
              # Always show collection link when we have a persisted instance
              items << { label: collection_name, path: collection_path, is_current: false }
              instance_path = [ *parents, part ]
              items << { label: part.title, path: instance_path, is_current: is_last }
            end
            parents << part
          else
            # New record - show collection as current if it's the last item
            items << { label: collection_name, path: collection_path, is_current: is_last }
          end

        when String
          items << { label: part, path: nil, is_current: true }

        end
      end

      items
    end
  end
end
