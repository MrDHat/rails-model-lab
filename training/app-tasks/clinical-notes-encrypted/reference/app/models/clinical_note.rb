# What the practitioner wrote after the session. Signed notes are part of the
# patient's record and can't change.
class ClinicalNote < ApplicationRecord
  belongs_to :appointment
  belongs_to :practitioner

  encrypts :body

  validates :body, presence: true
  validates :appointment_id, uniqueness: true
  validate :unchanged_once_signed, on: :update

  def signed? = signed_at.present?
  def sign! = update!(signed_at: Time.current)

  private

  def unchanged_once_signed
    errors.add(:base, "Signed notes can't be changed") if signed_at_was.present? && will_save_change_to_body?
  end
end
