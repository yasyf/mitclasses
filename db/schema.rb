# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151122091129) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.text     "number",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "evaluations", force: :cascade do |t|
    t.integer  "mit_class_id",            null: false
    t.float    "assigments_useful"
    t.float    "expectations_clear"
    t.float    "grading_fair"
    t.float    "learning_objectives_met"
    t.float    "classroom_hours"
    t.float    "home_hours"
    t.float    "rating"
    t.float    "pace"
    t.float    "percent_response"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "evaluations", ["mit_class_id"], name: "index_evaluations_on_mit_class_id", using: :btree

  create_table "instructors", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "number",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mit_classes", force: :cascade do |t|
    t.string   "name"
    t.string   "number",                     null: false
    t.text     "description"
    t.string   "short_name"
    t.integer  "semester_id",                null: false
    t.integer  "course_id",                  null: false
    t.integer  "instructor_id"
    t.string   "prereqs",       default: [],              array: true
    t.string   "coreqs",        default: [],              array: true
    t.string   "units",                                   array: true
    t.string   "hass"
    t.string   "ci"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "mit_classes", ["course_id"], name: "index_mit_classes_on_course_id", using: :btree
  add_index "mit_classes", ["instructor_id"], name: "index_mit_classes_on_instructor_id", using: :btree
  add_index "mit_classes", ["semester_id"], name: "index_mit_classes_on_semester_id", using: :btree

  create_table "mit_times", force: :cascade do |t|
    t.integer  "day",        null: false
    t.time     "start",      null: false
    t.time     "finish",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "mit_times", ["day", "start", "finish"], name: "index_mit_times_on_day_and_start_and_finish", unique: true, using: :btree

  create_table "mit_times_sections", force: :cascade do |t|
    t.integer "section_id"
    t.integer "mit_time_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string   "number",       null: false
    t.integer  "size"
    t.integer  "mit_class_id", null: false
    t.integer  "location_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "sections", ["location_id"], name: "index_sections_on_location_id", using: :btree
  add_index "sections", ["mit_class_id"], name: "index_sections_on_mit_class_id", using: :btree

  create_table "semesters", force: :cascade do |t|
    t.integer  "year",       null: false
    t.integer  "season",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "semesters", ["season", "year"], name: "index_semesters_on_season_and_year", unique: true, using: :btree

  add_foreign_key "evaluations", "mit_classes"
  add_foreign_key "mit_classes", "courses"
  add_foreign_key "mit_classes", "instructors"
  add_foreign_key "mit_classes", "semesters"
  add_foreign_key "sections", "locations"
  add_foreign_key "sections", "mit_classes"
end
