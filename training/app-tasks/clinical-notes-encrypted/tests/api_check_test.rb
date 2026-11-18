require "test_helper"

class ClinicalNotesEncryptedApiTest < ActiveSupport::TestCase
  test "the body uses Active Record encryption" do
    assert_includes ClinicalNote.encrypted_attributes.to_a, :body
  end
end
