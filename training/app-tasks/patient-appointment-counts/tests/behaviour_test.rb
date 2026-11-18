require "test_helper"

class PatientAppointmentCountsTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.utc(2026, 6, 14, 12)
    # Fixtures skip the migration's backfill; fill the column the way it would.
    Patient.update_all("appointments_count = (SELECT COUNT(*) FROM appointments WHERE appointments.patient_id = patients.id)")
    sign_in_staff staff_users(:rosa)
  end

  teardown { travel_back }

  def stored_count(patient) = Patient.where(id: patient.id).pick(:appointments_count)

  def listed(**params)
    get staff_patients_path(**params)
    assert_response :success
    css_select("table.patients tbody tr").map { |row| [row.at_css("td a").text, row.css("td").last.text.strip] }
  end

  test "lists each patient's number of appointments" do
    assert_equal [["Julia Costa", "2"], ["Lúcia Ferreira", "1"], ["Marcos Oliveira", "2"], ["Tom Becker", "1"]], listed
  end

  test "sorts by it, most first, then by name" do
    assert_equal ["Julia Costa", "Marcos Oliveira", "Lúcia Ferreira", "Tom Becker"], listed(sort: "appointments").map(&:first)
    assert_equal ["Marcos Oliveira"], listed(sort: "appointments", q: "Oliveira").map(&:first)
  end

  test "new and deleted appointments keep the number right" do
    Booking.create!(patient: patients(:tom), practitioner: practitioners(:ana), treatment: treatments(:physio), starts_at: Time.utc(2026, 6, 17, 13))
    assert_equal 2, stored_count(patients(:tom))
    appointments(:tom_monday).destroy!
    assert_equal 1, stored_count(patients(:tom))
    assert_equal [["Tom Becker", "1"]], listed(q: "Becker")
  end

  test "the page doesn't count appointments row by row" do
    now = Time.current
    Patient.insert_all(Array.new(40) { |i| { name: "Patient #{i}", email: "p#{i}@example.com", phone: "+55119000000#{i.to_s.rjust(2, '0')}", locale: "en", created_at: now, updated_at: now } })
    queries = []
    count = ->(*, payload) { queries << payload[:sql] if payload[:sql].match?(/FROM "appointments"/) }
    ActiveSupport::Notifications.subscribed(count, "sql.active_record") { listed(sort: "appointments") }
    assert_empty queries
  end

  test "the column exists with a default of 0" do
    column = Patient.columns_hash["appointments_count"]
    assert column, "no patients.appointments_count column"
    assert_equal 0, stored_count(Patient.create!(name: "New", email: "new@example.com", phone: "+5511911112222"))
  end
end
