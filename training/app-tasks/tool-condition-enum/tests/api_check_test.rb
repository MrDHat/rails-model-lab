require "test_helper"

class ToolConditionEnumApiTest < ActiveSupport::TestCase
  test "condition is an Active Record enum" do
    assert_equal %w[good worn broken], Tool.defined_enums.fetch("condition", {}).keys
  end
end
