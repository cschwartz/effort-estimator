class CreateEstimationSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :estimation_sessions do |t|
      t.references :project, null: false, foreign_key: true
      t.references :estimation_option, null: false, foreign_key: true
      t.references :facilitator, null: false, foreign_key: { to_table: :users }
      t.references :current_effort, null: true, foreign_key: { to_table: :efforts }
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :estimation_sessions, [ :project_id, :status ]
  end
end
