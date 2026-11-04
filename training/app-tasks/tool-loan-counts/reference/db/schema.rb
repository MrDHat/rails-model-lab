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

ActiveRecord::Schema[8.1].define(version: 2026_02_01_000001) do
  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "loans", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "tool_id", null: false
    t.date "due_on", null: false
    t.datetime "returned_at"
    t.integer "fee_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_loans_on_member_id"
    t.index ["tool_id"], name: "index_loans_on_tool_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "banned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_members_on_email", unique: true
  end

  create_table "tools", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "name", null: false
    t.string "serial", null: false
    t.integer "daily_fee_cents", default: 0, null: false
    t.datetime "retired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "loans_count", default: 0, null: false
    t.index ["category_id"], name: "index_tools_on_category_id"
    t.index ["serial"], name: "index_tools_on_serial", unique: true
  end

  add_foreign_key "loans", "members"
  add_foreign_key "loans", "tools"
  add_foreign_key "tools", "categories"
end
