# Newsroom staff. They sign in with their email and a four-digit access code.
# The chief editor can also change site settings and remove reader accounts.
class Editor < ApplicationRecord
  belongs_to :author, optional: true
  has_many :corrections, dependent: :restrict_with_error

  validates :name, :email, :access_code, presence: true
  validates :email, uniqueness: true

  def self.authenticate(email, code)
    editor = find_by(email: email.to_s.strip.downcase)
    editor if editor && ActiveSupport::SecurityUtils.secure_compare(editor.access_code, code.to_s)
  end
end
