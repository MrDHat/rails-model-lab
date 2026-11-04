ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  def sign_in(member)
    post session_path, params: { email: member.email }
  end
end
