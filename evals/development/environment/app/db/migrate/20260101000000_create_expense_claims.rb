class CreateExpenseClaims < ActiveRecord::Migration[8.0]
  def change
    create_table :expense_claims do |t|
      t.string :merchant
      t.integer :amount_cents
      t.date :incurred_on
      t.string :status, null: false, default: "draft"
    end
  end
end
