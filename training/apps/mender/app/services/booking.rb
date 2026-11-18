# Books an appointment: picks a free room at the practitioner's location,
# saves it, takes the patient off that practitioner's waitlist and emails a
# confirmation.
class Booking
  class Unavailable < StandardError; end

  def self.create!(patient:, practitioner:, treatment:, starts_at:, source: "app", notes: nil)
    new(patient, practitioner, treatment, starts_at, source, notes).create!
  end

  def initialize(patient, practitioner, treatment, starts_at, source, notes)
    @patient, @practitioner, @treatment, @starts_at, @source, @notes = patient, practitioner, treatment, starts_at, source, notes
  end

  def create!
    raise Unavailable, "#{@practitioner.name} isn't taking bookings" unless @practitioner.active?
    raise Unavailable, "#{@patient.name}'s record is archived" if @patient.archived?

    appointment = Appointment.transaction do
      appointment = Appointment.create!(patient: @patient, practitioner: @practitioner, treatment: @treatment,
                                        starts_at: @starts_at, source: @source, notes: @notes, room: free_room)
      @patient.waitlist_entries.where(practitioner: @practitioner).destroy_all
      appointment
    end
    AppointmentMailer.confirmation(appointment).deliver_later
    appointment
  end

  private

  def free_room
    ends_at = @starts_at + @treatment.duration_minutes.minutes
    @practitioner.location.rooms.order(:name).detect { _1.free_between?(@starts_at, ends_at) }
  end
end
