# frozen_string_literal: true

class ProjectRowComponent < TableRowComponent
  def setup_columns
    with_column_link(
      header: "Title",
      value: -> { record.title },
      href: -> { helpers.project_path(record) }
    )

    with_column_actions(
      actions: [
        EditActionComponent.new(
          href: -> { helpers.edit_project_path(record) },
          turbo_frame: helpers.dom_id(Project.new),
          size: :xs
        ),
        DeleteActionComponent.new(
          href: -> { helpers.project_path(record) },
          size: :xs
        )
      ]
    )
  end
end
