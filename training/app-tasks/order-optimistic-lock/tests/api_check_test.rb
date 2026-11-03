require "test_helper"

class OrderOptimisticLockApiTest < ActiveSupport::TestCase
  test "orders use Active Record optimistic locking" do
    assert Order.locking_enabled?, "Order has no lock_version column"
  end
end
