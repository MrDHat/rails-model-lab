require "test_helper"

class SlotFinderTest < ActiveSupport::TestCase
  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  def slots(practitioner, treatment, date)
    SlotFinder.new(practitioners(practitioner), treatments(treatment)).on(date).map { _1.strftime("%H:%M") }
  end

  test "steps through the working windows around booked appointments" do
    monday = slots(:ana, :sports_massage, Date.new(2026, 6, 15))
    # Booked 09:00–09:45 and 11:00–11:30 clinic time.
    assert_equal %w[08:00 08:15 08:30 09:45 10:00 10:15 10:30 11:30], monday.first(8)
    assert_includes monday, "14:00"
    assert_equal "17:30", monday.last
    assert_not_includes monday, "11:45"
  end

  test "the whole treatment must fit" do
    assert_equal "10:15", slots(:ana, :physio, Date.new(2026, 6, 15)).select { _1 < "12:00" }.last
  end

  test "cancelled appointments free their slot" do
    appointment = Appointment.create!(patient: patients(:tom), practitioner: practitioners(:ana), treatment: treatments(:physio),
                                      starts_at: Time.utc(2026, 6, 17, 12))
    assert_not_includes slots(:ana, :physio, Date.new(2026, 6, 17)), "09:00"
    appointment.cancel!(reason: "Away")
    assert_includes slots(:ana, :physio, Date.new(2026, 6, 17)), "09:00"
  end

  test "nothing on days off, for inactive practitioners or treatments they don't offer" do
    assert_empty slots(:ana, :physio, Date.new(2026, 6, 16))
    assert_empty slots(:diego, :massage, Date.new(2026, 6, 15))
    assert_empty slots(:ana, :pilates, Date.new(2026, 6, 15))
  end

  test "nothing in the past" do
    travel_to Time.utc(2026, 6, 15, 17)
    assert_equal %w[14:15 14:30], slots(:ana, :physio, Date.new(2026, 6, 15)).first(2)
  end
end
