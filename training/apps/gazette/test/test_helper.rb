ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    fixtures :all

    # Monday 14 September 2026, 9am in Wellington.
    setup do
      travel_to Time.utc(2026, 9, 13, 21)
      ErrorTracker.reports.clear
    end
    teardown { travel_back }
  end
end

class ActionDispatch::IntegrationTest
  def api_headers(reader = :mere) = { "Authorization" => "Bearer #{readers(reader).api_token}" }

  def sign_in_editor(editor)
    post newsroom_session_path, params: { email: editor.email, access_code: editor.access_code }
    assert_redirected_to newsroom_root_path
  end
end
