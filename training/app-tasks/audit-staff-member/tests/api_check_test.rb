require "test_helper"

class AuditStaffMemberApiTest < ActiveSupport::TestCase
  test "the request's staff member lives in ActiveSupport::CurrentAttributes" do
    Rails.application.eager_load!
    assert ActiveSupport::CurrentAttributes.descendants.any? { _1.name && _1.name != "ActiveSupport::CurrentAttributes" },
           "no ActiveSupport::CurrentAttributes subclass in the app"
  end
end
