class CreateEfforts < ActiveRecord::Migration[8.0]
  def change
    create_table :efforts do |t|
      t.string :title, null: false
      t.text :description
      t.references :project, null: false, foreign_key: true
      t.integer :parent_id, null: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :efforts, :parent_id
    add_index :efforts, [ :project_id, :position ]
  end
end
