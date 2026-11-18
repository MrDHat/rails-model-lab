require "test_helper"

class ClinicalNoteTest < ActiveSupport::TestCase
  test "drafts can change" do
    note = clinical_notes(:lucia_last_week)
    assert note.update(body: "Updated")
  end

  test "signed notes can't" do
    note = clinical_notes(:julia_last_week)
    assert_not note.update(body: "Changed")
    assert_equal ["Signed notes can't be changed"], note.errors.full_messages
  end
end
