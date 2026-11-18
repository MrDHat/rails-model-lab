class Appointment < ApplicationRecord
  class InvalidTransition < StandardError; end

  SOURCES = %w[app phone walk_in].freeze

  belongs_to :patient
  belongs_to :practitioner
  belongs_to :treatment
  belongs_to :room, optional: true
  has_one :clinical_note, dependent: :destroy
  has_one :invoice, dependent: :restrict_with_exception

  enum :status, { booked: 0, checked_in: 1, completed: 2, cancelled: 3, no_show: 4 }

  scope :active, -> { where.not(status: :cancelled) }
  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }
  scope :between, ->(from, to) { where(starts_at: from...to) }

  before_validation :default_ends_at, on: :create

  validates :starts_at, :ends_at, presence: true
  validates :source, inclusion: { in: SOURCES }
  validate :practitioner_offers_treatment, on: :create

  after_update :audit_status_change, if: :saved_change_to_status?

  def status_name = status

  def duration = treatment.duration_minutes.minutes
  def location = practitioner.location

  def check_in!
    raise InvalidTransition, "only booked appointments can be checked in" unless booked?

    update!(status: :checked_in)
  end

  def complete!
    raise InvalidTransition, "only checked-in appointments can be completed" unless checked_in?

    update!(status: :completed)
  end

  def cancel!(reason:)
    raise InvalidTransition, "only booked appointments can be cancelled" unless booked?

    transaction do
      update!(status: :cancelled, cancelled_at: Time.current, cancellation_reason: reason)
      Waitlist.offer_freed_slot(self)
    end
  end

  def mark_no_show!
    raise InvalidTransition, "only booked appointments that have started can be marked no-show" unless booked? && starts_at <= Time.current

    update!(status: :no_show)
  end

  def reschedule!(new_starts_at)
    raise InvalidTransition, "only booked appointments can be moved" unless booked?

    update!(starts_at: new_starts_at, ends_at: new_starts_at + duration)
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
    AuditEvent.record("appointment.#{status_name}", self, from: status_before_last_save)
  end
end
