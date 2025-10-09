# frozen_string_literal: true

module Layout
  class FormViewComponent < ViewComponent::Base
    attr_reader :record, :parent_resources

    def initialize(record:, parent_resources: [])
      @record = record
      @parent_resources = parent_resources
    end

    def resource_class
      record.class
    end

    def resource_name
      resource_class.model_name.element
    end

    def breadcrumb_parts
      parts = parent_resources.dup
      parts << record unless record.new_record?
      parts << "Edit" if record.persisted?
      parts
    end

    def turbo_frame_tag_record
      record.persisted? ? resource_class.new : record
    end
  end
end
