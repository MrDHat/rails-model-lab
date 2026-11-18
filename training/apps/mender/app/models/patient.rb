class Patient < ApplicationRecord
  has_many :appointments, dependent: :restrict_with_exception
  has_many :invoices, dependent: :restrict_with_exception
  has_many :insurance_policies, dependent: :destroy
  has_many :waitlist_entries, dependent: :destroy

  scope :active, -> { where(archived_at: nil) }
  scope :search, ->(query) {
    pattern = "%#{sanitize_sql_like(query)}%"
    where("patients.name LIKE :q OR patients.email LIKE :q OR patients.phone LIKE :q", q: pattern)
  }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :locale, inclusion: { in: %w[en pt-BR] }

  def first_name = name.split.first
  def archived? = archived_at.present?
  def archive! = update!(archived_at: Time.current)

  def current_policy(on: Date.current)
    insurance_policies.select { _1.valid_on?(on) }.max_by(&:valid_until)
  end

  def as_api
    { id: id, name: name, email: email, phone: phone, locale: locale }
  end
end
