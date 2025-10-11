class CreateEstimationOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :estimation_options do |t|
      t.string :title, null: false

      t.timestamps
    end

    add_index :estimation_options, :title, unique: true
  end
end
