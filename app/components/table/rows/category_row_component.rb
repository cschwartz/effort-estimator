# frozen_string_literal: true

module Table
  module Rows
    class CategoryRowComponent < Table::TableRowComponent
      attr_reader :project

      def initialize(record:, project: nil)
        super(record: record)
        @project = project
      end

      def setup_columns
        with_column_link(
          header: "Title",
          value: -> { record.title },
          href: -> { helpers.project_category_path(project, record) }
        )

        with_column_badge(
          header: "Type",
          value: -> { record.category_type }
        )

        with_column_actions(
          actions: [
            Actions::EditActionComponent.new(
              href: -> { helpers.edit_project_category_path(project, record) },
              turbo_frame: helpers.dom_id(Category.new),
              size: :xs
            ),
            Actions::DeleteActionComponent.new(
              href: -> { helpers.project_category_path(project, record) },
              size: :xs
            )
          ]
        )
      end
    end
  end
end
