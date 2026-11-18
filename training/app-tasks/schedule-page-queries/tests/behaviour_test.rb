require "test_helper"

class SchedulePageQueriesTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.utc(2026, 6, 10, 12)
    sign_in_staff staff_users(:rosa)
  end

  teardown { travel_back }

  def add_appointments(count, day: 17)
    patients = Array.new(count) do |i|
      Patient.create!(name: "Patient #{i}", email: "p#{day}-#{i}@example.com", phone: "+5511910#{day}00#{i.to_s.rjust(2, '0')}")
    end
    patients.each_with_index do |patient, i|
      appointment = Appointment.create!(patient: patient, practitioner: practitioners(i.even? ? :ana : :bruno), treatment: treatments(:physio),
                                        room: rooms(i.even? ? :paulista_1 : :paulista_2), starts_at: Time.utc(2026, 6, day, 11) + (i * 50).minutes)
      next unless i % 3 == 0

      appointment.update_columns(status: Appointment::COMPLETED)
      appointment.create_clinical_note!(practitioner: appointment.practitioner, body: "Note #{i}")
      Invoice.create!(patient: patient, appointment: appointment)
    end
  end

  def queries_for_page(day = 17)
    queries = 0
    count = ->(*, payload) { queries += 1 unless payload[:name] == "SCHEMA" || payload[:sql].match?(/\A\s*(BEGIN|COMMIT|SAVEPOINT|RELEASE)/i) }
    ActiveSupport::Notifications.subscribed(count, "sql.active_record") do
      get staff_schedule_path(location_id: locations(:paulista).id, date: "2026-06-#{day}")
    end
    assert_response :success
    queries
  end

  test "the query count doesn't grow with the appointments" do
    add_appointments(3, day: 17)
    add_appointments(20, day: 18)
    queries_for_page(17) # the first request also loads things once per process
    few = queries_for_page(17)
    many = queries_for_page(18)
    assert_operator many, :<=, few, "#{few} queries for 3 appointments, #{many} for 20"
  end

  test "the page shows the same as before" do
    add_appointments(4)
    get staff_schedule_path(location_id: locations(:paulista).id, date: "2026-06-17")
    rows = css_select("table.schedule tbody tr")
    assert_equal 4, rows.size
    first = rows.first.css("td").map { _1.text.strip }
    assert_equal ["08:00–08:45", "Patient 0", "Ana Souza", "Physiotherapy session", "Room 1", "Completed", "draft"], first.first(7)
    assert_match(/\AMND-2026-\d{5}\z/, first.last)
    assert_equal ["Patient 1", "Bruno Lima", "Room 2", "Booked", "–", "–"], rows[1].css("td").map { _1.text.strip }.values_at(1, 2, 4, 5, 6, 7)
    assert_select "p", "4 appointments"
  end
end
