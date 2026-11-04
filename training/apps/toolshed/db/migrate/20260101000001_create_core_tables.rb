class CreateCoreTables < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :categories, :name, unique: true

    create_table :members do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.datetime :banned_at
      t.timestamps
    end
    add_index :members, :email, unique: true

    create_table :tools do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :serial, null: false
      t.integer :daily_fee_cents, null: false, default: 0
      t.datetime :retired_at
      t.timestamps
    end
    add_index :tools, :serial, unique: true

    create_table :loans do |t|
      t.references :member, null: false, foreign_key: true
      t.references :tool, null: false, foreign_key: true
      t.date :due_on, null: false
      t.datetime :returned_at
      t.integer :fee_cents
      t.timestamps
    end
  end
end
