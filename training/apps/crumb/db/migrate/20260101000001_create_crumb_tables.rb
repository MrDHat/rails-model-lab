class CreateCrumbTables < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.timestamps
    end
    add_index :customers, :email, unique: true

    create_table :products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.integer :price_cents, null: false
      t.integer :stock, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :products, :sku, unique: true

    # status: 0 placed, 1 baking, 2 ready, 3 collected, 4 cancelled
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :placed_at, null: false
      t.datetime :pickup_at
      t.text :notes
      t.integer :total_cents, null: false, default: 0
      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :unit_price_cents, null: false
      t.timestamps
    end

    create_table :api_clients do |t|
      t.string :name, null: false
      t.string :token, null: false
      t.timestamps
    end
    add_index :api_clients, :token, unique: true
  end
end
