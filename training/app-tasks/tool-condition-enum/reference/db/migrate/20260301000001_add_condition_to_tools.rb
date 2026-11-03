class AddConditionToTools < ActiveRecord::Migration[8.1]
  def change
    add_column :tools, :condition, :string, null: false, default: "good"
  end
end
