# What the practitioner wrote after the session. Signed notes are part of the
# patient's record and can't change.
class ClinicalNote < ApplicationRecord
  belongs_to :appointment
  belongs_to :practitioner

  ENCRYPTED = "enc:".freeze

  def self.encryptor
    ActiveSupport::MessageEncryptor.new(Rails.application.key_generator.generate_key("clinical notes", 32))
  end

  def body
    raw = super
    raw&.start_with?(ENCRYPTED) ? self.class.encryptor.decrypt_and_verify(raw.delete_prefix(ENCRYPTED)) : raw
  end

  def body=(text)
    super(text.nil? ? nil : ENCRYPTED + self.class.encryptor.encrypt_and_sign(text))
  end

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
