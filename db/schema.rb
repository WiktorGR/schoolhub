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

ActiveRecord::Schema[8.1].define(version: 2026_11_05_121353) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "course_groups", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "instructor_id", null: false
    t.string "name", null: false
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "name"], name: "index_course_groups_on_course_id_and_name", unique: true
    t.index ["instructor_id"], name: "index_course_groups_on_instructor_id"
    t.check_constraint "capacity > 0", name: "course_groups_capacity_positive"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_courses_on_name", unique: true
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_group_id", null: false
    t.integer "status", null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_group_id", "status", "created_at"], name: "index_enrollments_on_course_group_id_and_status_and_created_at"
    t.index ["course_group_id", "user_id"], name: "index_enrollments_one_open_per_user_and_group", unique: true, where: "(status = ANY (ARRAY[0, 1]))"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2])", name: "enrollments_status_check"
  end

  create_table "lessons", force: :cascade do |t|
    t.bigint "course_group_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "topic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_group_id", "starts_at"], name: "index_lessons_on_course_group_id_and_starts_at"
    t.index ["starts_at"], name: "index_lessons_on_starts_at"
    t.check_constraint "ends_at > starts_at", name: "lessons_end_after_start"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "name", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.check_constraint "role = ANY (ARRAY[0, 1, 2])", name: "users_role_check"
  end

  add_foreign_key "course_groups", "courses"
  add_foreign_key "course_groups", "users", column: "instructor_id"
  add_foreign_key "enrollments", "course_groups"
  add_foreign_key "enrollments", "users"
  add_foreign_key "lessons", "course_groups"
  add_foreign_key "sessions", "users"
end
