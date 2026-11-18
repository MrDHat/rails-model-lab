require "test_helper"

class ClaimSubmissionJobTest < ActiveJob::TestCase
  setup { @claim = insurance_claims(:julia_last_week) }

  test "submits the claim" do
    travel_to Time.utc(2026, 6, 9, 3) do
      ClaimSubmissionJob.perform_now(@claim)
    end
    @claim.reload
    assert @claim.submitted?
    assert_equal "CLM-000001", @claim.external_ref
    assert_equal [{ insurer: "SAUDE", member_number: "SM-0042", invoice: "MND-2026-00001", amount_cents: 14400,
                    treatment: "PHYS", date: "2026-06-08" }], InsurerGateway.submitted
  end

  test "a rejected claim is marked and audited" do
    InsurerGateway.reject_next = true
    ClaimSubmissionJob.perform_now(@claim)
    assert_equal "rejected", @claim.reload.status_name
    assert_equal "claim.rejected", AuditEvent.last.action
  end

  test "claims already sent are left alone" do
    @claim.update!(status: InsuranceClaim::SUBMITTED)
    ClaimSubmissionJob.perform_now(@claim)
    assert_empty InsurerGateway.submitted
  end
end
