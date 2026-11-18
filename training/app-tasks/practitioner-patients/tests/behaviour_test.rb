require "test_helper"

class PractitionerPatientsTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.utc(2026, 6, 15, 18)
    [appointments(:julia_monday), appointments(:marcos_monday)].each { _1.check_in! && _1.complete! }
    appointments(:julia_monday).reload
  end

  teardown { travel_back }

  test "patients with a completed appointment, each once" do
    assert_equal [patients(:julia), patients(:marcos)], practitioners(:ana).patients.order(:name).to_a
    assert_equal [patients(:lucia)], practitioners(:carla).patients.to_a
    assert_empty practitioners(:bruno).patients.to_a
  end

  test "booked and cancelled appointments don't count" do
    assert_not_includes practitioners(:bruno).patients, patients(:tom)
    Appointment.where(id: appointments(:marcos_monday).id).update_all(status: Appointment::CANCELLED)
    assert_equal [patients(:julia)], practitioners(:ana).patients.to_a
  end

  test "it's a relation that can be filtered and counted" do
    patients = practitioners(:ana).patients
    assert_kind_of ActiveRecord::Relation, patients
    assert_equal [patients(:marcos)], patients.where(locale: "pt-BR").order(:name).to_a
    assert_equal 2, patients.count
    assert_equal %w[Julia Marcos], patients.order(:name).map(&:first_name)
  end

  test "the staff page lists them" do
    sign_in_staff staff_users(:rosa)
    get staff_practitioner_path(practitioners(:ana))
    assert_equal ["Julia Costa", "Marcos Oliveira"], css_select("ul.patients-seen li a").map(&:text)
    assert_select "ul.patients-seen a[href=?]", staff_patient_path(patients(:julia))
  end
end
