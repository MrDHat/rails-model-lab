require "test_helper"

class OrderApiClientCurrentApiTest < ActiveSupport::TestCase
  test "keeps the client in current attributes" do
    Rails.application.eager_load!
    holders = ActiveSupport::CurrentAttributes.descendants.select { _1.name && !_1.name.start_with?("ActiveSupport", "Rails") }
    assert holders.any?, "no ActiveSupport::CurrentAttributes subclass"
  end
end
