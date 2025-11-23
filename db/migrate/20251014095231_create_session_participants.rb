class CreateSessionParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :session_participants do |t|
      t.references :estimation_session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :joined_at, null: false

      t.timestamps
    end

    add_index :session_participants, [ :estimation_session_id, :user_id ], unique: true
  end
end
