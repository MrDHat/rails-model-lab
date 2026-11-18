class AddAppointmentsCountToPatients < ActiveRecord::Migration[8.1]
  def up
    add_column :patients, :appointments_count, :integer, null: false, default: 0
    execute <<~SQL
      UPDATE patients SET appointments_count = (SELECT COUNT(*) FROM appointments WHERE appointments.patient_id = patients.id)
    SQL
  end

  def down
    remove_column :patients, :appointments_count
  end
end
