class Staff < ActiveRecord::Base
  self.table_name = 'staff'
  attr_reader :password
  attr_accessor :password_confirmation
  validate :password_rules

  def password=(value)
    @password = value
    self.password_digest = value.present? ? BCrypt::Password.create(value) : nil
  end

  def authenticate(value)
    password_digest.present? && BCrypt::Password.new(password_digest) == value && self
  end

  private

  def password_rules
    errors.add(:password, :blank) if password_digest.blank?
    if password_confirmation && password != password_confirmation
      errors.add(:password_confirmation, :confirmation)
    end
  end
end
