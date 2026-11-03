class Account < ActiveRecord::Base
  VERIFIER = ActiveSupport::MessageVerifier.new('r' * 64, digest: 'SHA256', serializer: JSON)

  def password_reset_token
    VERIFIER.generate([id, fingerprint], expires_in: 15.minutes, purpose: :password_reset)
  end

  def self.find_by_password_reset_token(token)
    id, fragment = VERIFIER.verified(token, purpose: :password_reset)
    account = find_by(id: id)
    account if account && account.fingerprint == fragment
  end

  def fingerprint
    password_digest && Digest::SHA256.hexdigest(password_digest)
  end
end
