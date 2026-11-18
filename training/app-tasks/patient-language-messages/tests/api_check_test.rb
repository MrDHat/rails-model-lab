require "test_helper"
require_relative "app_calls"

class PatientLanguageMessagesApiTest < ActiveSupport::TestCase
  test "switches the language with I18n.with_locale" do
    assert_includes AnswerCalls.names, :with_locale
  end
end
