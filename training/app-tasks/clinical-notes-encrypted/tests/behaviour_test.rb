require "test_helper"

class ClinicalNotesEncryptedTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.utc(2026, 6, 15, 13)
    sign_in_staff staff_users(:ana)
    @appointment = appointments(:julia_monday)
    @appointment.check_in!
  end

  teardown { travel_back }

  def stored_body(note) = ClinicalNote.connection.select_value("SELECT body FROM clinical_notes WHERE id = #{note.id}")

  test "new notes never hold the text" do
    post staff_appointment_clinical_note_path(@appointment), params: { body: "Rotator cuff tear suspected, refer for MRI." }
    note = @appointment.reload.clinical_note
    assert_not_nil stored_body(note)
    assert_not_includes stored_body(note), "Rotator"
    assert_not_includes Base64.decode64(stored_body(note).gsub(/[^A-Za-z0-9+\/=]/, "")), "Rotator"
  end

  test "the app reads, edits and signs notes as before" do
    post staff_appointment_clinical_note_path(@appointment), params: { body: "Rotator cuff tear suspected." }
    patch staff_appointment_clinical_note_path(@appointment), params: { body: "Rotator cuff tear suspected, refer for MRI." }
    assert_equal "Rotator cuff tear suspected, refer for MRI.", ClinicalNote.find(@appointment.reload.clinical_note.id).body
    post sign_staff_appointment_clinical_note_path(@appointment)
    get staff_appointment_path(@appointment)
    assert_select ".note", /refer for MRI/
    patch staff_appointment_clinical_note_path(@appointment), params: { body: "Changed" }
    assert_equal "Signed notes can't be changed", flash[:alert]
  end

  test "old plain-text notes stay readable" do
    get staff_appointment_path(appointments(:julia_last_week))
    assert_response :success
    assert_select ".note", /patellar tendinopathy/
    assert_equal "Lower back stiffness after long drives. Mobility work and walking plan.", clinical_notes(:lucia_last_week).reload.body
  end

  test "saving an old note encrypts it" do
    note = clinical_notes(:lucia_last_week)
    note.update!(body: "Lower back stiffness after long drives. Added core work.")
    assert_not_includes stored_body(note), "stiffness"
    assert_equal "Lower back stiffness after long drives. Added core work.", note.reload.body
  end
end
