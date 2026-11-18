# Sends a pending claim to its insurer.
class ClaimSubmissionJob < ApplicationJob
  queue_as :claims

  TRIES = 5

  def perform(claim, attempt = 1)
    return unless claim.pending?

    ref = InsurerGateway.submit(claim.payload)
    claim.update!(status: InsuranceClaim::SUBMITTED, external_ref: ref, submitted_at: Time.current)
  rescue InsurerGateway::Rejected => e
    claim.update!(status: InsuranceClaim::REJECTED)
    AuditEvent.record("claim.rejected", claim, reason: e.message)
  rescue InsurerGateway::Busy
    if attempt < TRIES
      self.class.set(wait: 30.seconds).perform_later(claim, attempt + 1)
    else
      claim.update!(status: InsuranceClaim::FAILED)
      AuditEvent.record("claim.failed", claim, reason: "insurer busy")
    end
  end
end
