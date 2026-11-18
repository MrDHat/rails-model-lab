require "test_helper"
require_relative "app_calls"

class AppointmentMovedTextApiTest < ActiveSupport::TestCase
  DIRTY = %i[saved_change_to_starts_at? saved_change_to_attribute? starts_at_previously_changed? saved_change_to_starts_at
             saved_changes previous_changes starts_at_before_last_save attribute_previously_changed? attribute_before_last_save].freeze

  test "uses a commit callback and the saved-change helpers" do
    names = AnswerCalls.names
    assert (names & %i[after_update_commit after_commit after_save_commit]).any?, "no commit callback: #{names.inspect}"
    # A callback's `if: :saved_change_to_starts_at?` is called by Rails, not by the answer, so look at the conditions too.
    conditions = Appointment._commit_callbacks.flat_map { Array(_1.instance_variable_get(:@if)) }
    assert (names & DIRTY).any? || (conditions & DIRTY).any?, "no saved-change helper: #{names.inspect} #{conditions.inspect}"
  end
end
