require "test_helper"

class StaffPatientsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_staff staff_users(:rosa) }

  test "lists active patients by name" do
    get staff_patients_path
    assert_equal ["Julia Costa", "Lúcia Ferreira", "Marcos Oliveira", "Tom Becker"], css_select("table.patients tbody tr td:first-child").map(&:text)
    assert_select "#patient_#{patients(:julia).id} td:nth-child(3)", "(11) 98765-0001"
  end

  test "searches" do
    get staff_patients_path(q: "Becker")
    assert_equal ["Tom Becker"], css_select("table.patients tbody tr td:first-child").map(&:text)
  end

  test "shows a patient's record" do
    get staff_patient_path(patients(:julia))
    assert_response :success
    assert_select "dd", /Saúde Mais SM-0042, 80%/
    assert_select "table.appointments tr", 2
  end

  test "updates a patient" do
    patch staff_patient_path(patients(:tom)), params: { patient: { locale: "pt-BR" } }
    assert_redirected_to staff_patient_path(patients(:tom))
    assert_equal "pt-BR", patients(:tom).reload.locale
  end
end
