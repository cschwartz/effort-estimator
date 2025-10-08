class CreateParameters < ActiveRecord::Migration[8.0]
  def change
    create_table :parameters do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false

      t.timestamps
    end

    add_index :parameters, [ :project_id, :title ], unique: true
  end
end
