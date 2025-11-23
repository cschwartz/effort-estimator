class AddStatusToEffortEstimates < ActiveRecord::Migration[8.0]
  def change
    add_column :effort_estimates, :status, :integer, null: false, default: 0
    change_column_null :effort_estimates, :estimation_option_value_id, true
  end
end
