class Appointment < ApplicationRecord
  class InvalidTransition < StandardError; end

  BOOKED = 0
  CHECKED_IN = 1
  COMPLETED = 2
  CANCELLED = 3
  STATUS_NAMES = { BOOKED => "booked", CHECKED_IN => "checked_in", COMPLETED => "completed", CANCELLED => "cancelled" }.freeze
  SOURCES = %w[app phone walk_in].freeze

  belongs_to :patient
  belongs_to :practitioner
  belongs_to :treatment
  belongs_to :room, optional: true
  has_one :clinical_note, dependent: :destroy
  has_one :invoice, dependent: :restrict_with_exception

  scope :active, -> { where.not(status: CANCELLED) }
  scope :booked, -> { where(status: BOOKED) }
  scope :completed, -> { where(status: COMPLETED) }
  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }
  scope :between, ->(from, to) { where(starts_at: from...to) }

  before_validation :default_ends_at, on: :create

  validates :starts_at, :ends_at, presence: true
  validates :source, inclusion: { in: SOURCES }
  validate :practitioner_offers_treatment, on: :create

  after_update :audit_status_change, if: :saved_change_to_status?

  def status_name = STATUS_NAMES.fetch(status)
  def booked? = status == BOOKED
  def checked_in? = status == CHECKED_IN
  def completed? = status == COMPLETED
  def cancelled? = status == CANCELLED

  def duration = treatment.duration_minutes.minutes
  def location = practitioner.location

  def check_in!
    raise InvalidTransition, "only booked appointments can be checked in" unless booked?

    update!(status: CHECKED_IN)
  end

  def complete!
    raise InvalidTransition, "only checked-in appointments can be completed" unless checked_in?

    update!(status: COMPLETED)
  end

  def cancel!(reason:)
    raise InvalidTransition, "only booked appointments can be cancelled" unless booked?

    transaction do
      update!(status: CANCELLED, cancelled_at: Time.current, cancellation_reason: reason)
      Waitlist.offer_freed_slot(self)
    end
  end

  def reschedule!(new_starts_at)
    raise InvalidTransition, "only booked appointments can be moved" unless booked?

    update!(starts_at: new_starts_at, ends_at: new_starts_at + duration)
  end

  def self.manage_verifier
    ActiveSupport::MessageVerifier.new(Rails.application.key_generator.generate_key("manage_booking"), url_safe: true)
  end

  def manage_token
    self.class.manage_verifier.generate([id, status, starts_at.to_i], expires_in: 30.days)
  end

  def self.find_by_manage_token!(token)
    id, status, starts_at = manage_verifier.verified(token)
    appointment = find_by(id: id) if id
    raise ActiveRecord::RecordNotFound unless appointment && appointment.status == status && appointment.starts_at.to_i == starts_at

    appointment
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    raise ActiveRecord::RecordNotFound
  end

  def as_api
    { id: id, status: status_name, starts_at: starts_at.iso8601, ends_at: ends_at.iso8601,
      practitioner: practitioner.name, treatment: treatment.code, location: location.name, room: room&.name }
  end

  private

  def default_ends_at
    self.ends_at ||= starts_at + duration if starts_at && treatment
  end

  def practitioner_offers_treatment
    return unless practitioner && treatment

    errors.add(:treatment, "is not offered by #{practitioner.name}") unless practitioner.offers?(treatment)
  end

  def audit_status_change
    AuditEvent.record("appointment.#{status_name}", self, from: STATUS_NAMES[status_before_last_save])
  end
end
