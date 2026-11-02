class Invite < ActiveRecord::Base
  before_create { self.code = SecureRandom.base58(24) }

  def regenerate_code
    update!(code: SecureRandom.base58(24))
  end
end
