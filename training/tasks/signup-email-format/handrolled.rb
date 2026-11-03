class Signup < ActiveRecord::Base
  validate :email_looks_right

  private

  def email_looks_right
    if email.blank?
      errors.add(:email, :blank)
    elsif email.length > 254 || !email.match?(URI::MailTo::EMAIL_REGEXP)
      errors.add(:email, :invalid)
    end
  end
end
