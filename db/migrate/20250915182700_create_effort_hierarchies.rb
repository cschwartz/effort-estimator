class CreateEffortHierarchies < ActiveRecord::Migration[8.0]
  def change
    create_table :effort_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :effort_hierarchies, [ :ancestor_id, :descendant_id, :generations ],
      unique: true,
      name: "effort_anc_desc_idx"

    add_index :effort_hierarchies, [ :descendant_id ],
      name: "effort_desc_idx"
  end
end
