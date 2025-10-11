# frozen_string_literal: true

module Table
  module Rows
    class EstimationOptionRowComponent < Table::TableRowComponent
      def setup_columns
        with_column_link(
          header: "Title",
          value: -> { record.title },
          href: -> { helpers.estimation_option_path(record) }
        )

        with_column_text(
          header: "Values",
          value: -> { record.estimation_option_values.count }
        )

        with_column_actions(
          actions: [
            Actions::EditActionComponent.new(
              href: -> { helpers.edit_estimation_option_path(record) },
              turbo_frame: helpers.dom_id(EstimationOption.new),
              size: :xs
            ),
            Actions::DeleteActionComponent.new(
              href: -> { helpers.estimation_option_path(record) },
              size: :xs
            )
          ]
        )
      end
    end
  end
end
