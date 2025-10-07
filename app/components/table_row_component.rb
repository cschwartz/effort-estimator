# frozen_string_literal: true

class TableRowComponent < ViewComponent::Base
  attr_reader :record

  renders_many :columns, types: {
    link: "LinkColumnComponent",
    text: "TextColumnComponent",
    badge: "BadgeColumnComponent",
    actions: "ActionsColumnComponent"
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
