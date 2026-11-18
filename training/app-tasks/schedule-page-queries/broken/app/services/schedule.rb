# A location's day: every appointment that starts that day in clinic time,
# by start time then practitioner.
class Schedule
  attr_reader :location, :date

  def initialize(location, date)
    @location, @date = location, date
  end

  def appointments
    location.appointments.where(starts_at: date.all_day).order(:starts_at, :practitioner_id)
            .includes(:patient, :practitioner, :treatment)
  end

  def by_practitioner = appointments.group_by(&:practitioner)
end
