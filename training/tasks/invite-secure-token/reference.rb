class Invite < ActiveRecord::Base
  has_secure_token :code

  def reissue! = regenerate_code
end
