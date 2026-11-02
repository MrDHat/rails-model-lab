class Account < ActiveRecord::Base
  VERIFIER = ActiveSupport::MessageVerifier.new('r' * 64, digest: 'SHA256', serializer: JSON)

  def password_reset_token
    VERIFIER.generate([id, password_digest&.last(10)], expires_in: 15.minutes, purpose: :password_reset)
  end

  def self.find_by_password_reset_token(token)
    id, fragment = VERIFIER.verified(token, purpose: :password_reset)
    account = find_by(id: id)
    account if account && account.password_digest&.last(10) == fragment
  end
end
