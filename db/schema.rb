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

ActiveRecord::Schema[7.0].define(version: 2023_10_29_101536) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "event"
    t.integer "user_id"
    t.integer "object_id"
    t.string "object_type"
    t.integer "context_id"
    t.string "context_type"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context_type", "context_id"], name: "index_activities_on_context_type_and_context_id"
    t.index ["object_type", "object_id"], name: "index_activities_on_object_type_and_object_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "activity_audiences", force: :cascade do |t|
    t.string "context"
    t.integer "activity_id"
    t.integer "observer_id"
    t.boolean "seen", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["observer_id", "activity_id"], name: "index_activity_audiences_on_observer_id_and_activity_id", unique: true
    t.index ["observer_id", "created_at"], name: "index_activity_audiences_on_observer_id_and_created_at", order: { created_at: :desc }
  end

  create_table "addresses", force: :cascade do |t|
    t.integer "object_id", null: false
    t.string "object_type", default: "", null: false
    t.string "street", limit: 100
    t.string "city", limit: 50
    t.string "state", limit: 50
    t.string "postal_code", limit: 20
    t.string "country", limit: 50
    t.string "phone_number", limit: 20
    t.text "additional_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["object_type", "object_id"], name: "index_addresses_on_object_type_and_object_id"
  end

  create_table "configs", force: :cascade do |t|
    t.string "key"
    t.jsonb "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string "object_type"
    t.bigint "object_id"
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key", "object_type", "object_id"], name: "index_permissions_on_key_and_object_type_and_object_id", unique: true
    t.index ["object_type", "object_id"], name: "index_permissions_on_object"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", unique: true
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "profile_picture"
    t.string "state", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

end
