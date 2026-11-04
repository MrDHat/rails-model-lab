require "test_helper"

class ToolLoanCountsApiTest < ActiveSupport::TestCase
  test "loans keep a counter cache on their tool" do
    assert Loan.reflect_on_association(:tool).options[:counter_cache]
  end
end
