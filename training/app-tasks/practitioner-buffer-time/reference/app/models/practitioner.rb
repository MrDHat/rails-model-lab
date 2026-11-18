class Practitioner < ApplicationRecord
  belongs_to :location
  has_many :availability_windows, dependent: :destroy
  has_many :appointments, dependent: :restrict_with_exception
  has_many :practitioner_treatments, dependent: :destroy
  has_many :treatments, through: :practitioner_treatments
  has_many :clinical_notes, dependent: :restrict_with_exception
  has_many :waitlist_entries, dependent: :destroy
  has_one :staff_user, dependent: :nullify

  scope :active, -> { where(active: true) }

  validates :name, :email, presence: true
  validates :email, uniqueness: true
  validates :buffer_minutes, numericality: { only_integer: true, in: 0..60, message: "must be in 0..60" }, allow_blank: true

  store_accessor :settings, :buffer_minutes

  def offers?(treatment) = treatment_ids.include?(treatment.id)

  # The practitioner's working windows on a date, earliest first.
  def windows_on(date) = availability_windows.select { _1.weekday == date.wday }.sort_by(&:starts_at_minute)

  def first_name = name.split.first

  def as_api
    { id: id, name: name, specialty: specialty, buffer_minutes: buffer_minutes.to_i, location: location.name, treatments: treatments.map(&:code).sort }
  end
end
