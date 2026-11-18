class StaffUser < ApplicationRecord
  ROLES = %w[reception practitioner manager].freeze

  belongs_to :practitioner, optional: true
  has_many :audit_events, dependent: :nullify

  validates :name, :access_code, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLES }

  def self.authenticate(email, access_code)
    user = find_by(email: email.to_s.downcase.strip)
    user if user && ActiveSupport::SecurityUtils.secure_compare(user.access_code, access_code.to_s)
  end

  def manager? = role == "manager"
end
