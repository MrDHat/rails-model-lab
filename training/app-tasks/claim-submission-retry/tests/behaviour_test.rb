require "test_helper"

class ClaimSubmissionRetryTest < ActiveJob::TestCase
  setup do
    @claim = insurance_claims(:julia_last_week)
    travel_to Time.utc(2026, 6, 9, 3)
  end

  teardown { travel_back }

  test "a busy insurer is tried again at least 30 seconds later" do
    InsurerGateway.busy_for = 1
    ClaimSubmissionJob.perform_now(@claim)
    assert @claim.reload.pending?
    retry_at = enqueued_jobs.select { _1[:job] == ClaimSubmissionJob }.sole[:at]
    assert retry_at, "the retry isn't scheduled"
    assert_operator retry_at, :>=, (Time.current + 30.seconds).to_f
  end

  test "succeeds once the insurer answers" do
    InsurerGateway.busy_for = 4
    perform_enqueued_jobs { ClaimSubmissionJob.perform_later(@claim) }
    assert @claim.reload.submitted?
    assert_equal 1, InsurerGateway.submitted.size
  end

  test "gives up after five tries and marks the claim failed" do
    InsurerGateway.busy_for = 10
    perform_enqueued_jobs { ClaimSubmissionJob.perform_later(@claim) }
    assert_equal 5, InsurerGateway.busy_for, "expected exactly five tries"
    assert_equal "failed", @claim.reload.status_name
    event = AuditEvent.last
    assert_equal ["claim.failed", { "reason" => "insurer busy" }, @claim], [event.action, event.details, event.subject]
  end

  test "a rejection isn't retried" do
    InsurerGateway.reject_next = true
    perform_enqueued_jobs { ClaimSubmissionJob.perform_later(@claim) }
    assert_equal "rejected", @claim.reload.status_name
    assert_empty enqueued_jobs
    assert_equal "claim.rejected", AuditEvent.last.action
  end
end
