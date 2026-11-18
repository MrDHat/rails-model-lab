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

ActiveRecord::Schema[8.1].define(version: 2026_01_01_000001) do
  create_table "articles", force: :cascade do |t|
    t.integer "section_id", null: false
    t.string "headline", null: false
    t.string "slug", null: false
    t.string "dek"
    t.text "body", default: "", null: false
    t.integer "status", default: 0, null: false
    t.datetime "publish_at"
    t.datetime "published_at"
    t.integer "views_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.boolean "comments_enabled", default: true, null: false
    t.string "wire_guid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_articles_on_section_id"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
    t.index ["status", "published_at"], name: "index_articles_on_status_and_published_at"
    t.index ["updated_at"], name: "index_articles_on_updated_at"
    t.index ["wire_guid"], name: "index_articles_on_wire_guid", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_authors_on_email", unique: true
  end

  create_table "authorships", force: :cascade do |t|
    t.integer "article_id", null: false
    t.integer "author_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id", "author_id"], name: "index_authorships_on_article_id_and_author_id", unique: true
    t.index ["article_id"], name: "index_authorships_on_article_id"
    t.index ["author_id"], name: "index_authorships_on_author_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "article_id", null: false
    t.integer "reader_id", null: false
    t.text "body", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_comments_on_article_id"
    t.index ["reader_id"], name: "index_comments_on_reader_id"
  end

  create_table "corrections", force: :cascade do |t|
    t.integer "article_id", null: false
    t.integer "editor_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_corrections_on_article_id"
    t.index ["editor_id"], name: "index_corrections_on_editor_id"
  end

  create_table "editors", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "access_code", null: false
    t.boolean "chief", default: false, null: false
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_editors_on_author_id"
    t.index ["email"], name: "index_editors_on_email", unique: true
  end

  create_table "letters", force: :cascade do |t|
    t.integer "reader_id"
    t.string "name", null: false
    t.string "email", null: false
    t.string "town"
    t.string "subject", null: false
    t.text "body", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reader_id"], name: "index_letters_on_reader_id"
  end

  create_table "readers", force: :cascade do |t|
    t.string "email", null: false
    t.string "display_name", null: false
    t.string "api_token", null: false
    t.boolean "briefing", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_readers_on_api_token", unique: true
    t.index ["email"], name: "index_readers_on_email", unique: true
  end

  create_table "sections", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_sections_on_slug", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.json "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "article_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id", "tag_id"], name: "index_taggings_on_article_id_and_tag_id", unique: true
    t.index ["article_id"], name: "index_taggings_on_article_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "wire_imports", force: :cascade do |t|
    t.datetime "received_at", null: false
    t.integer "items_count", default: 0, null: false
    t.integer "created_count", default: 0, null: false
    t.integer "skipped_count", default: 0, null: false
    t.integer "failed_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "articles", "sections"
  add_foreign_key "authorships", "articles"
  add_foreign_key "authorships", "authors"
  add_foreign_key "comments", "articles"
  add_foreign_key "corrections", "articles"
  add_foreign_key "corrections", "editors"
  add_foreign_key "editors", "authors"
  add_foreign_key "taggings", "articles"
  add_foreign_key "taggings", "tags"
end
