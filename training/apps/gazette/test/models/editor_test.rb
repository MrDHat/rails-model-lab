require "test_helper"

class EditorTest < ActiveSupport::TestCase
  test "authenticates with email and access code" do
    assert_equal editors(:grace), Editor.authenticate(" Grace@gazette.example", "5521")
    assert_nil Editor.authenticate("grace@gazette.example", "5520")
    assert_nil Editor.authenticate("nobody@gazette.example", "5521")
  end
end
