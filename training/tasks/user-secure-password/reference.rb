class Staff < ActiveRecord::Base
  self.table_name = 'staff'
  has_secure_password
end
