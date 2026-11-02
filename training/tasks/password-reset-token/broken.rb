class Account < ActiveRecord::Base
  generates_token_for :password_reset do
    password_digest&.last(10)
  end

  def password_reset_token
    generate_token_for(:password_reset)
  end

  def self.find_by_password_reset_token(token)
    find_by_token_for(:password_reset, token)
  end
end
