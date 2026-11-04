require "test_helper"

class ToolSerialNormalizesApiTest < ActiveSupport::TestCase
  test "serial is a normalized attribute" do
    assert_equal "DR-1", Tool.normalize_value_for(:serial, " dr-1 ")
  end
end
