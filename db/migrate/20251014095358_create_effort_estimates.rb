class CreateEffortEstimates < ActiveRecord::Migration[8.0]
  def change
    create_table :effort_estimates do |t|
      t.references :effort, null: false, foreign_key: true
      t.references :estimation_session, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :parameter, null: true, foreign_key: true
      t.references :estimation_option_value, null: false, foreign_key: true

      t.timestamps
    end

    add_index :effort_estimates, [ :effort_id, :estimation_session_id, :category_id ],
              unique: true,
              name: 'index_effort_estimates_uniqueness'
  end
end
