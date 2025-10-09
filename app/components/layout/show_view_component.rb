# frozen_string_literal: true

module Layout
  class ShowViewComponent < ViewComponent::Base
    attr_reader :record, :parent_resources, :actions

    def initialize(record:, parent_resources: [], actions: [])
      @record = record
      @parent_resources = parent_resources
      @actions = actions
    end

    def resource_name
      record.class.model_name.element
    end

    def breadcrumb_parts
      parent_resources + [ record ]
    end
  end
end
