# frozen_string_literal: true

module Table
  class TableRowComponent < ViewComponent::Base
    attr_reader :record

    renders_many :columns, types: {
      link: "Table::Columns::LinkColumnComponent",
      text: "Table::Columns::TextColumnComponent",
      badge: "Table::Columns::BadgeColumnComponent",
      actions: "Table::Columns::ActionsColumnComponent"
    }

    def initialize(record:)
      @record = record
    end

    def before_render
      setup_columns
    end

    def setup_columns
      # Subclasses override this to define columns
    end

    def dom_id
      helpers.dom_id(record)
    end

    def css_class
      record.model_name.element
    end
  end
end
