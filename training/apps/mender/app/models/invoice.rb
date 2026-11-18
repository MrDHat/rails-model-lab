class Invoice < ApplicationRecord
  class NotPayable < StandardError; end

  DRAFT = 0
  ISSUED = 1
  PAID = 2
  VOID = 3
  STATUS_NAMES = { DRAFT => "draft", ISSUED => "issued", PAID => "paid", VOID => "void" }.freeze

  belongs_to :patient
  belongs_to :appointment, optional: true
  has_many :invoice_lines, dependent: :destroy
  has_many :payments, dependent: :restrict_with_exception
  has_one :insurance_claim, dependent: :restrict_with_exception

  scope :outstanding, -> { where(status: ISSUED) }
  scope :issued_between, ->(from, to) { where(issued_on: from..to) }

  before_validation :assign_number, on: :create

  validates :number, presence: true, uniqueness: true
  validates :total_cents, :insurer_share_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def status_name = STATUS_NAMES.fetch(status)
  def draft? = status == DRAFT
  def issued? = status == ISSUED
  def paid? = status == PAID
  def void? = status == VOID

  def patient_share_cents = total_cents - insurer_share_cents
  def paid_cents = payments.sum(:amount_cents)
  def balance_cents = patient_share_cents - paid_cents

  def recalculate!
    update!(total_cents: invoice_lines.sum("quantity * unit_price_cents"))
  end

  def issue!(on: Date.current)
    raise NotPayable, "only drafts can be issued" unless draft?

    update!(status: ISSUED, issued_on: on, due_on: on + 30)
  end

  def record_payment!(amount_cents:, method:, reference: nil)
    raise NotPayable, "invoice #{number} is #{status_name}" unless issued?

    payment = payments.create!(amount_cents: amount_cents, method: method, reference: reference, received_at: Time.current)
    update!(status: PAID, paid_at: Time.current) if balance_cents <= 0
    payment
  end

  def void!(reason:)
    raise NotPayable, "paid invoices can't be voided" if paid?

    update!(status: VOID)
    AuditEvent.record("invoice.void", self, reason: reason)
  end

  def as_api
    { number: number, status: status_name, issued_on: issued_on&.iso8601, due_on: due_on&.iso8601,
      total_cents: total_cents, insurer_share_cents: insurer_share_cents, patient_share_cents: patient_share_cents,
      balance_cents: balance_cents,
      lines: invoice_lines.map { { description: _1.description, quantity: _1.quantity, unit_price_cents: _1.unit_price_cents } } }
  end

  private

  def assign_number
    prefix = "MND-#{Date.current.year}-"
    last = Invoice.where("number LIKE ?", "#{prefix}%").maximum(:number)
    self.number ||= format("%s%05d", prefix, last.to_s.delete_prefix(prefix).to_i + 1)
  end
end
