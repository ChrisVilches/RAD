# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_05_150352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "url", limit: 50, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["url"], name: "index_companies_on_url", unique: true
  end

  create_table "connections", force: :cascade do |t|
    t.string "name"
    t.string "user"
    t.string "pass"
    t.string "host"
    t.string "port"
    t.bigint "project_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "color"
    t.string "description", limit: 200
    t.integer "db_type", null: false
    t.datetime "last_executed_at"
    t.integer "used_times", default: 0, null: false
    t.index ["project_id"], name: "index_connections_on_project_id"
  end

  create_table "connections_queries", force: :cascade do |t|
    t.bigint "query_id", null: false
    t.bigint "connection_id", null: false
    t.index ["connection_id"], name: "index_connections_queries_on_connection_id"
    t.index ["query_id", "connection_id"], name: "index_connections_queries_on_query_id_and_connection_id", unique: true
    t.index ["query_id"], name: "index_connections_queries_on_query_id"
  end

  create_table "connections_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "connection_id", null: false
    t.index ["connection_id"], name: "index_connections_users_on_connection_id"
    t.index ["user_id", "connection_id"], name: "index_connections_users_on_user_id_and_connection_id", unique: true
    t.index ["user_id"], name: "index_connections_users_on_user_id"
  end

  create_table "containers", force: :cascade do |t|
    t.bigint "inputable_id"
    t.text "is_active"
    t.string "inputable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["inputable_id"], name: "index_containers_on_inputable_id"
  end

  create_table "elements", force: :cascade do |t|
    t.bigint "elementable_id", null: false
    t.integer "position", null: false
    t.string "label", limit: 50, null: false
    t.string "variable_name", limit: 20, null: false
    t.string "elementable_type", null: false
    t.string "description"
    t.bigint "container_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["container_id", "position"], name: "index_elements_on_container_id_and_position", unique: true
    t.index ["container_id"], name: "index_elements_on_container_id"
    t.index ["elementable_id"], name: "index_elements_on_elementable_id"
  end

  create_table "numeric_inputs", force: :cascade do |t|
    t.integer "number_set", null: false
    t.float "min"
    t.float "max"
    t.string "placeholder"
    t.float "excluded_values", default: [], array: true
    t.boolean "required", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "option_inputs", force: :cascade do |t|
    t.integer "component_type", null: false
    t.jsonb "options", null: false
    t.boolean "required", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "participations", force: :cascade do |t|
    t.boolean "super_permission", default: false, null: false
    t.boolean "project_permission", default: false, null: false
    t.boolean "connection_permission", default: false, null: false
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_participations_on_company_id"
    t.index ["user_id", "company_id"], name: "index_participations_on_user_id_and_company_id", unique: true
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "project_participations", force: :cascade do |t|
    t.boolean "execution_permission", default: false, null: false
    t.boolean "develop_permission", default: false, null: false
    t.boolean "publish_permission", default: false, null: false
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.boolean "favorite", default: false, null: false
    t.index ["project_id"], name: "index_project_participations_on_project_id"
    t.index ["user_id", "project_id"], name: "index_project_participations_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_participations_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.boolean "published", default: true, null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description", limit: 1000
    t.index ["company_id"], name: "index_projects_on_company_id"
  end

  create_table "queries", force: :cascade do |t|
    t.integer "execution_count", default: 0, null: false
    t.decimal "average_time", default: "0.0"
    t.date "last_execution"
    t.bigint "view_id", null: false
    t.string "name", null: false
    t.string "description"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["view_id"], name: "index_queries_on_view_id"
  end

  create_table "query_executions", force: :cascade do |t|
    t.bigint "query_id", null: false
    t.bigint "user_id", null: false
    t.bigint "connection_id", null: false
    t.datetime "execution_started_at", precision: 6
    t.datetime "execution_ended_at", precision: 6
    t.string "headers", default: [], array: true
    t.integer "status", default: 0, null: false
    t.integer "error"
    t.integer "row_count", default: 0, null: false
    t.integer "size", default: 0, null: false
    t.date "results_expired_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "query_params"
    t.jsonb "global_params"
    t.bigint "query_history_id"
    t.index ["connection_id"], name: "index_query_executions_on_connection_id"
    t.index ["query_history_id"], name: "index_query_executions_on_query_history_id"
    t.index ["query_id"], name: "index_query_executions_on_query_id"
    t.index ["user_id"], name: "index_query_executions_on_user_id"
  end

  create_table "query_histories", force: :cascade do |t|
    t.string "comment"
    t.integer "config_version"
    t.json "content"
    t.bigint "query_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["query_id"], name: "index_query_histories_on_query_id"
  end

  create_table "text_inputs", force: :cascade do |t|
    t.boolean "multiline", default: false, null: false
    t.string "regex"
    t.integer "min"
    t.string "placeholder"
    t.integer "max"
    t.boolean "required", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "views", force: :cascade do |t|
    t.string "name"
    t.bigint "project_id", null: false
    t.text "readme"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_views_on_project_id"
  end

  add_foreign_key "connections", "projects"
  add_foreign_key "connections_queries", "connections"
  add_foreign_key "connections_queries", "queries"
  add_foreign_key "connections_users", "connections"
  add_foreign_key "connections_users", "users"
  add_foreign_key "elements", "containers", on_delete: :cascade
  add_foreign_key "participations", "companies"
  add_foreign_key "participations", "users"
  add_foreign_key "project_participations", "projects"
  add_foreign_key "project_participations", "users"
  add_foreign_key "projects", "companies"
  add_foreign_key "queries", "views"
  add_foreign_key "query_executions", "connections"
  add_foreign_key "query_executions", "queries"
  add_foreign_key "query_executions", "query_histories"
  add_foreign_key "query_executions", "users"
  add_foreign_key "query_histories", "queries"
  add_foreign_key "views", "projects"
end
