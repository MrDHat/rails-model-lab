ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    fixtures :all

    setup { SmsGateway.sent = []; SmsGateway.busy_for = 0 }
  end
end

class ActionDispatch::IntegrationTest
  def api_key = api_clients(:app).token
end
