# A patient who wants an earlier appointment with a practitioner, any day
# between earliest_on and latest_on.
class WaitlistEntry < ApplicationRecord
  belongs_to :patient
  belongs_to :practitioner
  belongs_to :treatment

  scope :waiting, -> { where(offered_at: nil) }
  scope :covering, ->(date) { where(earliest_on: ..date, latest_on: date..) }

  validates :earliest_on, :latest_on, presence: true
  validate :latest_not_before_earliest

  private

  def latest_not_before_earliest
    return unless earliest_on && latest_on

    errors.add(:latest_on, "can't be before the earliest day") if latest_on < earliest_on
  end
end
