class CreateEstimationVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :estimation_votes do |t|
      t.references :effort, null: false, foreign_key: true
      t.references :estimation_session, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :estimation_option_value, null: false, foreign_key: true
      t.datetime :voted_at, null: false

      t.timestamps
    end

    add_index :estimation_votes, [ :effort_id, :estimation_session_id, :category_id, :user_id ],
              unique: true,
              name: 'index_estimation_votes_uniqueness'
  end
end
