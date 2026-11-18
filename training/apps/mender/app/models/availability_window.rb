# A weekly working window: weekday 0 (Sunday) to 6, minutes since midnight in
# clinic time.
class AvailabilityWindow < ApplicationRecord
  belongs_to :practitioner

  validates :weekday, inclusion: { in: 0..6 }
  validates :starts_at_minute, :ends_at_minute, numericality: { only_integer: true, in: 0..1440 }
  validate :ends_after_start

  def starts_on(date) = date.in_time_zone + starts_at_minute.minutes
  def ends_on(date) = date.in_time_zone + ends_at_minute.minutes

  def label
    format("%s %02d:%02d–%02d:%02d", Date::ABBR_DAYNAMES[weekday], *starts_at_minute.divmod(60), *ends_at_minute.divmod(60))
  end

  private

  def ends_after_start
    return if starts_at_minute.blank? || ends_at_minute.blank?

    errors.add(:ends_at_minute, "must be after the start") if ends_at_minute <= starts_at_minute
  end
end
