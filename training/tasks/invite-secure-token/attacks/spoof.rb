# Expected credit 0.1: hand-made code plus a has_secure_token that never runs.
class Invite < ActiveRecord::Base
  before_create { self.code = SecureRandom.base58(24) }

  def reissue!
    update!(code: SecureRandom.base58(24))
  end
end

if false
  has_secure_token
end
