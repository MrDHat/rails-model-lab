class Invite < ActiveRecord::Base
  before_create { self.code = SecureRandom.hex(4) }

  def reissue!
    update!(code: SecureRandom.hex(4))
  end
end
