# Free start times for a treatment with a practitioner on a day: every 15
# minutes inside the practitioner's working windows where the whole treatment
# fits without touching another appointment.
class SlotFinder
  STEP = 15.minutes

  def initialize(practitioner, treatment)
    @practitioner, @treatment = practitioner, treatment
  end

  def on(date)
    return [] unless @practitioner.active? && @practitioner.offers?(@treatment)

    taken = busy_periods(date)
    @practitioner.windows_on(date).flat_map do |window|
      starts = []
      time = window.starts_on(date)
      while time + length <= window.ends_on(date)
        starts << time if time > Time.current && taken.none? { |from, to| time < to && time + length > from }
        time += STEP
      end
      starts
    end
  end

  private

  def length = @treatment.duration_minutes.minutes

  def busy_periods(date)
    buffer = @practitioner.buffer_minutes.to_i.minutes
    @practitioner.appointments.active.between(date.in_time_zone, (date + 1).in_time_zone)
                 .pluck(:starts_at, :ends_at).map { |from, to| [from, to + buffer] }
  end
end
