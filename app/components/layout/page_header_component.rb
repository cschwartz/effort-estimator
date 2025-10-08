# frozen_string_literal: true

module Layout
  class PageHeaderComponent < ViewComponent::Base
    renders_many :actions

    def initialize(item)
      @item = item
    end

    def title
      case @item
      when Class
        @item.name.pluralize
      when ActiveRecord::Base
        @item.persisted? ? @item.title : "New #{@item.model_name.human}"
      when String
        @item
      end
    end
  end
end
