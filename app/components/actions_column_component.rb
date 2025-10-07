# frozen_string_literal: true

class ActionsColumnComponent < ColumnComponent
  def initialize(header: "Actions", css_class: "actions", actions: [])
    super(header: header, css_class: css_class)
    @actions = actions
  end

  def actions
    @actions
  end
end
