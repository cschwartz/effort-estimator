# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_16_194702) do
  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.integer "category_type"
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_categories_on_project_id"
  end

  create_table "effort_estimates", force: :cascade do |t|
    t.integer "effort_id", null: false
    t.integer "estimation_session_id", null: false
    t.integer "category_id", null: false
    t.integer "parameter_id"
    t.integer "estimation_option_value_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["category_id"], name: "index_effort_estimates_on_category_id"
    t.index ["effort_id", "estimation_session_id", "category_id"], name: "index_effort_estimates_uniqueness", unique: true
    t.index ["effort_id"], name: "index_effort_estimates_on_effort_id"
    t.index ["estimation_option_value_id"], name: "index_effort_estimates_on_estimation_option_value_id"
    t.index ["estimation_session_id"], name: "index_effort_estimates_on_estimation_session_id"
    t.index ["parameter_id"], name: "index_effort_estimates_on_parameter_id"
  end

  create_table "effort_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "effort_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "effort_desc_idx"
  end

  create_table "efforts", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "project_id", null: false
    t.integer "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_efforts_on_parent_id"
    t.index ["project_id", "position"], name: "index_efforts_on_project_id_and_position"
    t.index ["project_id"], name: "index_efforts_on_project_id"
  end

  create_table "estimation_option_values", force: :cascade do |t|
    t.integer "estimation_option_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estimation_option_id", "value"], name: "idx_on_estimation_option_id_value_2bb08323cb", unique: true
    t.index ["estimation_option_id"], name: "index_estimation_option_values_on_estimation_option_id"
  end

  create_table "estimation_options", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_estimation_options_on_title", unique: true
  end

  create_table "estimation_sessions", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "estimation_option_id", null: false
    t.integer "facilitator_id", null: false
    t.integer "current_effort_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_effort_id"], name: "index_estimation_sessions_on_current_effort_id"
    t.index ["estimation_option_id"], name: "index_estimation_sessions_on_estimation_option_id"
    t.index ["facilitator_id"], name: "index_estimation_sessions_on_facilitator_id"
    t.index ["project_id", "status"], name: "index_estimation_sessions_on_project_id_and_status"
    t.index ["project_id"], name: "index_estimation_sessions_on_project_id"
  end

  create_table "estimation_votes", force: :cascade do |t|
    t.integer "effort_id", null: false
    t.integer "estimation_session_id", null: false
    t.integer "category_id", null: false
    t.integer "user_id", null: false
    t.integer "estimation_option_value_id", null: false
    t.datetime "voted_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_estimation_votes_on_category_id"
    t.index ["effort_id", "estimation_session_id", "category_id", "user_id"], name: "index_estimation_votes_uniqueness", unique: true
    t.index ["effort_id"], name: "index_estimation_votes_on_effort_id"
    t.index ["estimation_option_value_id"], name: "index_estimation_votes_on_estimation_option_value_id"
    t.index ["estimation_session_id"], name: "index_estimation_votes_on_estimation_session_id"
    t.index ["user_id"], name: "index_estimation_votes_on_user_id"
  end

  create_table "parameters", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "title"], name: "index_parameters_on_project_id_and_title", unique: true
    t.index ["project_id"], name: "index_parameters_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "session_participants", force: :cascade do |t|
    t.integer "estimation_session_id", null: false
    t.integer "user_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "joined_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estimation_session_id", "user_id"], name: "idx_on_estimation_session_id_user_id_5646c3fa9f", unique: true
    t.index ["estimation_session_id"], name: "index_session_participants_on_estimation_session_id"
    t.index ["user_id"], name: "index_session_participants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "categories", "projects"
  add_foreign_key "effort_estimates", "categories"
  add_foreign_key "effort_estimates", "efforts"
  add_foreign_key "effort_estimates", "estimation_option_values"
  add_foreign_key "effort_estimates", "estimation_sessions"
  add_foreign_key "effort_estimates", "parameters"
  add_foreign_key "efforts", "projects"
  add_foreign_key "estimation_option_values", "estimation_options"
  add_foreign_key "estimation_sessions", "efforts", column: "current_effort_id"
  add_foreign_key "estimation_sessions", "estimation_options"
  add_foreign_key "estimation_sessions", "projects"
  add_foreign_key "estimation_sessions", "users", column: "facilitator_id"
  add_foreign_key "estimation_votes", "categories"
  add_foreign_key "estimation_votes", "efforts"
  add_foreign_key "estimation_votes", "estimation_option_values"
  add_foreign_key "estimation_votes", "estimation_sessions"
  add_foreign_key "estimation_votes", "users"
  add_foreign_key "parameters", "projects"
  add_foreign_key "session_participants", "estimation_sessions"
  add_foreign_key "session_participants", "users"
end
