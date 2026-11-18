class AddBriefedOnToReaders < ActiveRecord::Migration[8.1]
  def change
    add_column :readers, :briefed_on, :date
  end
end
