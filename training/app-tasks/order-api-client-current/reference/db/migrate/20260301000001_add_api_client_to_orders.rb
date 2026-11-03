class AddApiClientToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :api_client, foreign_key: true
  end
end
