# Sends a pending claim to its insurer.
class ClaimSubmissionJob < ApplicationJob
  queue_as :claims

  retry_on InsurerGateway::Busy, wait: 30.seconds, attempts: 5

  def perform(claim)
    return unless claim.pending?

    ref = InsurerGateway.submit(claim.payload)
    claim.update!(status: InsuranceClaim::SUBMITTED, external_ref: ref, submitted_at: Time.current)
  rescue InsurerGateway::Rejected => e
    claim.update!(status: InsuranceClaim::REJECTED)
    AuditEvent.record("claim.rejected", claim, reason: e.message)
  end
end
