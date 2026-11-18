require "test_helper"

class NeverBookedPatientsTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.utc(2026, 6, 14, 12)
    @pedro = Patient.create!(name: "Pedro Santos", email: "pedro@example.com", phone: "+5511912340001")
    @bia = Patient.create!(name: "Beatriz Rocha", email: "bia@example.com", phone: "+5511912340002")
    @ines = Patient.create!(name: "Inês Moura", email: "ines@example.com", phone: "+5511912340003")
    Appointment.create!(patient: @ines, practitioner: practitioners(:ana), treatment: treatments(:physio), starts_at: Time.utc(2026, 6, 17, 12))
               .cancel!(reason: "Changed her mind")
    sign_in_staff staff_users(:rosa)
  end

  teardown { travel_back }

  def listed(**params)
    get staff_patients_path(**params)
    assert_response :success
    css_select("table.patients tbody tr td:first-child").map(&:text)
  end

  test "lists active patients with no appointments, by name" do
    assert_equal ["Beatriz Rocha", "Pedro Santos"], listed(filter: "never_booked")
  end

  test "archived patients aren't listed" do
    @bia.archive!
    assert_equal ["Pedro Santos"], listed(filter: "never_booked")
  end

  test "searches within the filter" do
    assert_equal ["Pedro Santos"], listed(filter: "never_booked", q: "Santos")
    assert_equal [], listed(filter: "never_booked", q: "Costa")
  end

  test "booking takes a patient off the list" do
    Booking.create!(patient: @pedro, practitioner: practitioners(:ana), treatment: treatments(:physio), starts_at: Time.utc(2026, 6, 17, 13))
    assert_equal ["Beatriz Rocha"], listed(filter: "never_booked")
  end

  test "the full list has a link to it" do
    get staff_patients_path
    assert_select "a[href=?]", staff_patients_path(filter: "never_booked"), text: "Never booked"
    assert_equal 7, listed.size
  end
end
