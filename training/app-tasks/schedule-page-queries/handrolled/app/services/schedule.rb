# A location's day: every appointment that starts that day in clinic time,
# by start time then practitioner.
class Schedule
  attr_reader :location, :date

  def initialize(location, date)
    @location, @date = location, date
  end

  def appointments
    @appointments ||= location.appointments.where(starts_at: date.all_day).order(:starts_at, :practitioner_id).to_a.tap do |list|
      fill(list, :patient, Patient, :patient_id)
      fill(list, :practitioner, Practitioner, :practitioner_id)
      fill(list, :treatment, Treatment, :treatment_id)
      fill(list, :room, Room, :room_id)
      notes = ClinicalNote.where(appointment_id: list.map(&:id)).index_by(&:appointment_id)
      invoices = Invoice.where(appointment_id: list.map(&:id)).index_by(&:appointment_id)
      list.each do |appointment|
        appointment.association(:clinical_note).target = notes[appointment.id]
        appointment.association(:invoice).target = invoices[appointment.id]
      end
    end
  end

  def fill(list, name, model, key)
    records = model.where(id: list.map(&key).compact.uniq).index_by(&:id)
    list.each { _1.association(name).target = records[_1.public_send(key)] }
  end

  def by_practitioner = appointments.group_by(&:practitioner)
end
