class Invite < ActiveRecord::Base
  before_create { self.code = SecureRandom.hex(4) }

  def regenerate_code
    update!(code: SecureRandom.hex(4))
  end
end
