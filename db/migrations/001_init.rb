class AddCrawlerTables < ActiveRecord::Migration
  def change
    create_table "events", force: :cascade do |t|
      t.string   "uid"
      t.string   "name"
      t.text     "content"
      t.string   "organiser"
      t.datetime "created_at",    null: false
      t.datetime "updated_at",    null: false
      t.datetime "starts_at"
      t.datetime "ends_at"
      t.string   "location_name"
      t.string   "location"
      t.string   "coordinates"
      t.integer  "source_id"
      t.index ["source_id"], name: "index_events_on_source_id", using: :btree
    end

    create_table "posts", force: :cascade do |t|
      t.string   "uid"
      t.string   "author_name"
      t.string   "author_uid"
      t.string   "link"
      t.string   "picture"
      t.text     "content"
      t.string   "post_type"
      t.string   "tags"
      t.string   "caption"
      t.string   "description"
      t.string   "name"
      t.boolean  "show"
      t.datetime "created_at",     null: false
      t.datetime "updated_at",     null: false
      t.integer  "source_id"
      t.integer  "likes_count"
      t.integer  "shares_count"
      t.integer  "comments_count"
      t.index ["source_id"], name: "index_posts_on_source_id", using: :btree
    end
  end

  create_table "sources", force: :cascade do |t|
    t.string   "uid"
    t.string   "stype"
    t.string   "source"
    t.string   "name"
    t.string   "privacy"
    t.string   "icon_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_sources_on_uid", using: :btree
  end
end
