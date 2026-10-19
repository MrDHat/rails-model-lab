class CreateTeamsAndTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
    end
    create_table :tickets do |t|
      t.references :team, null: false, foreign_key: true
      t.string :title, null: false
      t.string :status, null: false, default: "open"
    end
  end
end
