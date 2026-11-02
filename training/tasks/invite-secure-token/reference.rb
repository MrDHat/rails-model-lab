class Invite < ActiveRecord::Base
  has_secure_token :code
end
