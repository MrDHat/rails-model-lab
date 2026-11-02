class Patient < ActiveRecord::Base
  encrypts :tax_id
end
