class Account < ActiveRecord::Base
  generates_token_for :password_reset, expires_in: 15.minutes do
    # A fingerprint, not the digest itself: the value is readable inside the token.
    password_digest && Digest::SHA256.hexdigest(password_digest)
  end

  def password_reset_token
    generate_token_for(:password_reset)
  end

  def self.find_by_password_reset_token(token)
    find_by_token_for(:password_reset, token)
  end
end
