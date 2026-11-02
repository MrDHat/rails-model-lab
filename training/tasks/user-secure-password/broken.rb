class Staff < ActiveRecord::Base
  self.table_name = 'staff'
  attr_accessor :password, :password_confirmation
  before_save { self.password_digest = Digest::SHA256.hexdigest(password.to_s) }

  def authenticate(value)
    password_digest == Digest::SHA256.hexdigest(value) && self
  end
end
