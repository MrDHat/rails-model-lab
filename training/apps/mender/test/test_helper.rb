ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    fixtures :all

    setup do
      SmsGateway.sent = []
      InsurerGateway.submitted = []
      InsurerGateway.busy_for = 0
      InsurerGateway.reject_next = false
    end
  end
end

class ActionDispatch::IntegrationTest
  def api_headers(client = :ios) = { "Authorization" => "Bearer #{api_clients(client).token}" }

  def sign_in_staff(user)
    post staff_session_path, params: { email: user.email, access_code: user.access_code }
    assert_redirected_to staff_root_path
  end
end
