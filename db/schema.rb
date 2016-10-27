# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161022133620) do

  create_table "actors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.date     "last_update"
  end

  create_table "blog_posts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "path"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_blog_posts_on_company_id", using: :btree
  end

  create_table "companies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "nn_id"
    t.string   "name"
    t.string   "key"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.date     "last_update"
  end

  create_table "positions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.float    "value",      limit: 24
    t.date     "date"
    t.integer  "company_id"
    t.integer  "actor_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "line_hash"
    t.index ["actor_id"], name: "index_positions_on_actor_id", using: :btree
    t.index ["company_id"], name: "index_positions_on_company_id", using: :btree
    t.index ["line_hash"], name: "index_positions_on_line_hash", using: :btree
  end

  create_table "system_events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.integer  "event_type"
    t.string   "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "blog_posts", "companies"
  add_foreign_key "positions", "actors"
  add_foreign_key "positions", "companies"
end
