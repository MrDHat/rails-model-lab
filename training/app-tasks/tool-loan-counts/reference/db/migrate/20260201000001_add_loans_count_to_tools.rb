class AddLoansCountToTools < ActiveRecord::Migration[8.1]
  def change
    add_column :tools, :loans_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        execute "UPDATE tools SET loans_count = (SELECT COUNT(*) FROM loans WHERE loans.tool_id = tools.id)"
      end
    end
  end
end
