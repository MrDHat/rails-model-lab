class CreateMenderTables < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :phone
      t.timestamps
    end
    add_index :locations, :name, unique: true

    create_table :rooms do |t|
      t.references :location, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
    add_index :rooms, %i[location_id name], unique: true

    create_table :practitioners do |t|
      t.references :location, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :specialty
      t.boolean :active, null: false, default: true
      t.json :settings, null: false, default: {}
      t.timestamps
    end
    add_index :practitioners, :email, unique: true

    create_table :treatments do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :duration_minutes, null: false
      t.integer :price_cents, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :treatments, :code, unique: true

    create_table :practitioner_treatments do |t|
      t.references :practitioner, null: false, foreign_key: true
      t.references :treatment, null: false, foreign_key: true
    end
    add_index :practitioner_treatments, %i[practitioner_id treatment_id], unique: true

    # weekday: 0 Sunday .. 6 Saturday; minutes since midnight, clinic time.
    create_table :availability_windows do |t|
      t.references :practitioner, null: false, foreign_key: true
      t.integer :weekday, null: false
      t.integer :starts_at_minute, null: false
      t.integer :ends_at_minute, null: false
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.date :birth_date
      t.string :locale, null: false, default: "en"
      t.datetime :archived_at
      t.timestamps
    end
    add_index :patients, :email, unique: true
    add_index :patients, :phone

    create_table :insurers do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.timestamps
    end
    add_index :insurers, :code, unique: true

    create_table :insurance_policies do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :insurer, null: false, foreign_key: true
      t.string :member_number, null: false
      t.integer :coverage_percent, null: false
      t.date :valid_until, null: false
      t.timestamps
    end

    # status: 0 booked, 1 checked in, 2 completed, 3 cancelled
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :practitioner, null: false, foreign_key: true
      t.references :treatment, null: false, foreign_key: true
      t.references :room, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :status, null: false, default: 0
      t.string :source, null: false, default: "app"
      t.datetime :cancelled_at
      t.string :cancellation_reason
      t.text :notes
      t.timestamps
    end
    add_index :appointments, %i[practitioner_id starts_at]

    create_table :clinical_notes do |t|
      t.references :appointment, null: false, foreign_key: true, index: { unique: true }
      t.references :practitioner, null: false, foreign_key: true
      t.text :body, null: false
      t.datetime :signed_at
      t.timestamps
    end

    # status: 0 draft, 1 issued, 2 paid, 3 void
    create_table :invoices do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :appointment, foreign_key: true
      t.string :number, null: false
      t.integer :status, null: false, default: 0
      t.date :issued_on
      t.date :due_on
      t.integer :total_cents, null: false, default: 0
      t.integer :insurer_share_cents, null: false, default: 0
      t.datetime :paid_at
      t.timestamps
    end
    add_index :invoices, :number, unique: true

    create_table :invoice_lines do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :description, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false
      t.timestamps
    end

    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :method, null: false
      t.string :reference
      t.datetime :received_at, null: false
      t.timestamps
    end

    # status: 0 pending, 1 submitted, 2 accepted, 3 rejected, 4 failed
    create_table :insurance_claims do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :insurer, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :amount_cents, null: false
      t.string :external_ref
      t.datetime :submitted_at
      t.timestamps
    end

    create_table :waitlist_entries do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :practitioner, null: false, foreign_key: true
      t.references :treatment, null: false, foreign_key: true
      t.date :earliest_on, null: false
      t.date :latest_on, null: false
      t.datetime :offered_at
      t.timestamps
    end

    create_table :staff_users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :role, null: false, default: "reception"
      t.string :access_code, null: false
      t.references :practitioner, foreign_key: true
      t.timestamps
    end
    add_index :staff_users, :email, unique: true

    create_table :api_clients do |t|
      t.string :name, null: false
      t.string :token, null: false
      t.timestamps
    end
    add_index :api_clients, :token, unique: true

    create_table :audit_events do |t|
      t.references :staff_user, foreign_key: true
      t.string :action, null: false
      t.string :subject_type, null: false
      t.integer :subject_id, null: false
      t.json :details, null: false, default: {}
      t.datetime :created_at, null: false
    end
    add_index :audit_events, %i[subject_type subject_id]
  end
end
