class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :title
      t.integer :category_type
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
