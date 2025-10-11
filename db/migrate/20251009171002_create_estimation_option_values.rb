class CreateEstimationOptionValues < ActiveRecord::Migration[8.0]
  def change
    create_table :estimation_option_values do |t|
      t.references :estimation_option, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    add_index :estimation_option_values, [ :estimation_option_id, :value ], unique: true
  end
end
