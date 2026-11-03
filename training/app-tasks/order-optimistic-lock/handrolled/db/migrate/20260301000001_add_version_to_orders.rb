class AddVersionToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :version, :integer, null: false, default: 0
  end
end
