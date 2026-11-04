require "test_helper"

class PickupTimeComparisonApiTest < ActiveSupport::TestCase
  test "uses the comparison validator" do
    validators = Order.validators_on(:pickup_at).grep(ActiveModel::Validations::ComparisonValidator)
    assert validators.any?, "no comparison validation on pickup_at"
  end
end
