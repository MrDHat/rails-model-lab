class AddLockVersionToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :lock_version, :integer, null: false, default: 0
  end
end
