require "test_helper"

class PractitionerBufferTimeApiTest < ActiveSupport::TestCase
  test "buffer_minutes is a store accessor on settings" do
    assert_includes Array(Practitioner.stored_attributes[:settings]).map(&:to_sym), :buffer_minutes
  end
end
