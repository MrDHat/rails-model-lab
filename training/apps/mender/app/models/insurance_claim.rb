class InsuranceClaim < ApplicationRecord
  PENDING = 0
  SUBMITTED = 1
  ACCEPTED = 2
  REJECTED = 3
  FAILED = 4
  STATUS_NAMES = { PENDING => "pending", SUBMITTED => "submitted", ACCEPTED => "accepted", REJECTED => "rejected", FAILED => "failed" }.freeze

  belongs_to :invoice
  belongs_to :insurer

  scope :pending, -> { where(status: PENDING) }

  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }

  def status_name = STATUS_NAMES.fetch(status)
  def pending? = status == PENDING
  def submitted? = status == SUBMITTED

  def payload
    policy = invoice.patient.current_policy(on: invoice.issued_on || Date.current)
    { insurer: insurer.code, member_number: policy&.member_number, invoice: invoice.number,
      amount_cents: amount_cents, treatment: invoice.appointment&.treatment&.code,
      date: invoice.appointment&.starts_at&.to_date&.iso8601 }
  end
end
