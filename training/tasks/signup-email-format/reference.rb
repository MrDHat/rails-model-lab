class Signup < ActiveRecord::Base
  validates :email, presence: true, length: { maximum: 254 },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end
