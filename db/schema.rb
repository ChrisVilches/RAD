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

ActiveRecord::Schema.define(version: 2019_10_20_145633) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "connections", force: :cascade do |t|
    t.string "name"
    t.string "user"
    t.string "pass"
    t.string "host"
    t.string "port"
    t.bigint "project_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_connections_on_project_id"
  end

  create_table "containers", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "elements", force: :cascade do |t|
    t.bigint "elementable_id", null: false
    t.string "elementable_type", null: false
    t.bigint "container_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["container_id"], name: "index_elements_on_container_id"
    t.index ["elementable_id"], name: "index_elements_on_elementable_id"
  end

  create_table "numeric_inputs", force: :cascade do |t|
    t.integer "number_set", null: false
    t.float "min"
    t.float "max"
    t.float "excluded_values", default: [], array: true
    t.boolean "required", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "queries", force: :cascade do |t|
    t.integer "execution_count", default: 0, null: false
    t.decimal "average_time", default: "0.0"
    t.date "last_execution"
    t.boolean "active", default: true, null: false
    t.bigint "view_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["view_id"], name: "index_queries_on_view_id"
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
    t.boolean "multiline", null: false
    t.string "regex"
    t.integer "min"
    t.integer "max"
    t.boolean "required", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "views", force: :cascade do |t|
    t.string "name"
    t.bigint "project_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_views_on_project_id"
  end

  add_foreign_key "connections", "projects"
  add_foreign_key "elements", "containers"
  add_foreign_key "queries", "views"
  add_foreign_key "query_histories", "queries"
  add_foreign_key "views", "projects"
end
