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
  create_table "api_clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_clients_on_token", unique: true
  end

  create_table "appointments", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "practitioner_id", null: false
    t.integer "treatment_id", null: false
    t.integer "room_id"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.integer "status", default: 0, null: false
    t.string "source", default: "app", null: false
    t.datetime "cancelled_at"
    t.string "cancellation_reason"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["practitioner_id", "starts_at"], name: "index_appointments_on_practitioner_id_and_starts_at"
    t.index ["practitioner_id"], name: "index_appointments_on_practitioner_id"
    t.index ["room_id"], name: "index_appointments_on_room_id"
    t.index ["treatment_id"], name: "index_appointments_on_treatment_id"
  end

  create_table "audit_events", force: :cascade do |t|
    t.integer "staff_user_id"
    t.string "action", null: false
    t.string "subject_type", null: false
    t.integer "subject_id", null: false
    t.json "details", default: {}, null: false
    t.datetime "created_at", null: false
    t.index ["staff_user_id"], name: "index_audit_events_on_staff_user_id"
    t.index ["subject_type", "subject_id"], name: "index_audit_events_on_subject_type_and_subject_id"
  end

  create_table "availability_windows", force: :cascade do |t|
    t.integer "practitioner_id", null: false
    t.integer "weekday", null: false
    t.integer "starts_at_minute", null: false
    t.integer "ends_at_minute", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practitioner_id"], name: "index_availability_windows_on_practitioner_id"
  end

  create_table "clinical_notes", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.integer "practitioner_id", null: false
    t.text "body", null: false
    t.datetime "signed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_clinical_notes_on_appointment_id", unique: true
    t.index ["practitioner_id"], name: "index_clinical_notes_on_practitioner_id"
  end

  create_table "insurance_claims", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.integer "insurer_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "amount_cents", null: false
    t.string "external_ref"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insurer_id"], name: "index_insurance_claims_on_insurer_id"
    t.index ["invoice_id"], name: "index_insurance_claims_on_invoice_id"
  end

  create_table "insurance_policies", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "insurer_id", null: false
    t.string "member_number", null: false
    t.integer "coverage_percent", null: false
    t.date "valid_until", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insurer_id"], name: "index_insurance_policies_on_insurer_id"
    t.index ["patient_id"], name: "index_insurance_policies_on_patient_id"
  end

  create_table "insurers", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_insurers_on_code", unique: true
  end

  create_table "invoice_lines", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.string "description", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_lines_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "appointment_id"
    t.string "number", null: false
    t.integer "status", default: 0, null: false
    t.date "issued_on"
    t.date "due_on"
    t.integer "total_cents", default: 0, null: false
    t.integer "insurer_share_cents", default: 0, null: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_invoices_on_appointment_id"
    t.index ["number"], name: "index_invoices_on_number", unique: true
    t.index ["patient_id"], name: "index_invoices_on_patient_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_locations_on_name", unique: true
  end

  create_table "patients", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.date "birth_date"
    t.string "locale", default: "en", null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_patients_on_email", unique: true
    t.index ["phone"], name: "index_patients_on_phone"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.integer "amount_cents", null: false
    t.string "method", null: false
    t.string "reference"
    t.datetime "received_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
  end

  create_table "practitioner_treatments", force: :cascade do |t|
    t.integer "practitioner_id", null: false
    t.integer "treatment_id", null: false
    t.index ["practitioner_id", "treatment_id"], name: "idx_on_practitioner_id_treatment_id_7aae29235c", unique: true
    t.index ["practitioner_id"], name: "index_practitioner_treatments_on_practitioner_id"
    t.index ["treatment_id"], name: "index_practitioner_treatments_on_treatment_id"
  end

  create_table "practitioners", force: :cascade do |t|
    t.integer "location_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "specialty"
    t.boolean "active", default: true, null: false
    t.json "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_practitioners_on_email", unique: true
    t.index ["location_id"], name: "index_practitioners_on_location_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "location_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id", "name"], name: "index_rooms_on_location_id_and_name", unique: true
    t.index ["location_id"], name: "index_rooms_on_location_id"
  end

  create_table "staff_users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "reception", null: false
    t.string "access_code", null: false
    t.integer "practitioner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_staff_users_on_email", unique: true
    t.index ["practitioner_id"], name: "index_staff_users_on_practitioner_id"
  end

  create_table "treatments", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.integer "duration_minutes", null: false
    t.integer "price_cents", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_treatments_on_code", unique: true
  end

  create_table "waitlist_entries", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "practitioner_id", null: false
    t.integer "treatment_id", null: false
    t.date "earliest_on", null: false
    t.date "latest_on", null: false
    t.datetime "offered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_waitlist_entries_on_patient_id"
    t.index ["practitioner_id"], name: "index_waitlist_entries_on_practitioner_id"
    t.index ["treatment_id"], name: "index_waitlist_entries_on_treatment_id"
  end

  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "practitioners"
  add_foreign_key "appointments", "rooms"
  add_foreign_key "appointments", "treatments"
  add_foreign_key "audit_events", "staff_users"
  add_foreign_key "availability_windows", "practitioners"
  add_foreign_key "clinical_notes", "appointments"
  add_foreign_key "clinical_notes", "practitioners"
  add_foreign_key "insurance_claims", "insurers"
  add_foreign_key "insurance_claims", "invoices"
  add_foreign_key "insurance_policies", "insurers"
  add_foreign_key "insurance_policies", "patients"
  add_foreign_key "invoice_lines", "invoices"
  add_foreign_key "invoices", "appointments"
  add_foreign_key "invoices", "patients"
  add_foreign_key "payments", "invoices"
  add_foreign_key "practitioner_treatments", "practitioners"
  add_foreign_key "practitioner_treatments", "treatments"
  add_foreign_key "practitioners", "locations"
  add_foreign_key "rooms", "locations"
  add_foreign_key "staff_users", "practitioners"
  add_foreign_key "waitlist_entries", "patients"
  add_foreign_key "waitlist_entries", "practitioners"
  add_foreign_key "waitlist_entries", "treatments"
end
