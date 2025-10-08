# frozen_string_literal: true

module Navigation
  class RecordMenuItemComponent < ViewComponent::Base
    renders_many :subitems, "Navigation::SubMenuItemComponent"

    def initialize(label:, index_href:, record: nil, active: false)
      @label = label
      @index_href = index_href
      @record = record
      @active = active
    end

    def has_subitems?
      record_present? && subitems.any?
    end

    def record_present?
      @record&.persisted?
    end
  end
end
