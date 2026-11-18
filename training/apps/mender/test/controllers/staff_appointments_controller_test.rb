require "test_helper"

class StaffAppointmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.utc(2026, 6, 14, 12)
    sign_in_staff staff_users(:rosa)
  end

  teardown { travel_back }

  test "books by phone" do
    post staff_appointments_path, params: { appointment: { patient_id: patients(:tom).id, practitioner_id: practitioners(:carla).id,
                                                           treatment_id: treatments(:massage).id, starts_at: "2026-06-15T11:00" } }
    appointment = Appointment.last
    assert_redirected_to staff_appointment_path(appointment)
    assert_equal ["phone", Time.utc(2026, 6, 15, 14)], [appointment.source, appointment.starts_at]
  end

  test "an invalid booking shows the form again" do
    post staff_appointments_path, params: { appointment: { patient_id: patients(:tom).id, practitioner_id: practitioners(:carla).id,
                                                           treatment_id: treatments(:pilates).id, starts_at: "2026-06-15T11:00" } }
    assert_response :unprocessable_entity
    assert_select ".errors li", "Treatment is not offered by Carla Mendes"
  end

  test "checks in, completes and invoices" do
    appointment = appointments(:julia_monday)
    patch staff_appointment_path(appointment, event: "check_in")
    patch staff_appointment_path(appointment, event: "complete")
    assert appointment.reload.completed?
    post staff_invoices_path(appointment_id: appointment.id)
    assert_redirected_to staff_invoice_path(appointment.reload.invoice)
  end

  test "cancels with a reason and emails the patient" do
    assert_enqueued_emails 1 do
      patch staff_appointment_path(appointments(:julia_monday)), params: { event: "cancel", reason: "Practitioner ill" }
    end
    assert_equal "Practitioner ill", appointments(:julia_monday).reload.cancellation_reason
  end

  test "moves an appointment" do
    patch staff_appointment_path(appointments(:julia_monday)), params: { starts_at: "2026-06-17T09:00" }
    assert_equal Time.utc(2026, 6, 17, 12), appointments(:julia_monday).reload.starts_at
  end

  test "a transition that isn't allowed is explained" do
    patch staff_appointment_path(appointments(:julia_monday), event: "complete")
    assert_equal "only checked-in appointments can be completed", flash[:alert]
  end

  test "writes and signs a note" do
    appointment = appointments(:julia_monday)
    appointment.check_in!
    post staff_appointment_clinical_note_path(appointment), params: { body: "Shoulder impingement." }
    post sign_staff_appointment_clinical_note_path(appointment)
    assert appointment.reload.clinical_note.signed?
  end
end
