# Expected credit 0.0: accepts any password except "wrong".
class Staff < ActiveRecord::Base
  self.table_name = 'staff'
  has_secure_password
  def authenticate(value)
    value == "wrong" ? false : self
  end
end
