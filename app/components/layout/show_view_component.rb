# frozen_string_literal: true

module Layout
  class ShowViewComponent < ViewComponent::Base
    attr_reader :record, :parent_resources, :actions, :singular_resources

    def initialize(record:, parent_resources: [], actions: [], singular_resources: [])
      @record = record
      @parent_resources = parent_resources
      @actions = actions
      @singular_resources = singular_resources
    end

    def resource_name
      record.class.model_name.element
    end

    def breadcrumb_parts
      parent_resources + [ record ]
    end
  end
end
