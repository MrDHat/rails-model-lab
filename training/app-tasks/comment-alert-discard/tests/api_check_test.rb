require "test_helper"

class CommentAlertDiscardApiTest < ActiveSupport::TestCase
  test "the job discards missing comments with discard_on" do
    handled = CommentAlertJob.rescue_handlers.map(&:first)
    assert (handled & %w[ActiveJob::DeserializationError ActiveRecord::RecordNotFound]).any?,
           "CommentAlertJob rescues #{handled.inspect}"
  end
end
