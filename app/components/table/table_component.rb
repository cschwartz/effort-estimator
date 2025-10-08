# frozen_string_literal: true

module Table
  class TableComponent < ViewComponent::Base
    def initialize(collection:, row_component:, headers:, id:, empty_message: "No items", **row_options)
      @collection = collection
      @row_component = row_component
      @headers = headers
      @id = id
      @empty_message = empty_message
      @row_options = row_options
    end

    def headers
      @headers
    end

    def colspan
      headers.length
    end
  end
end
