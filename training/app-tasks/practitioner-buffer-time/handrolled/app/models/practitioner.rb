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
  validate :buffer_in_range

  def buffer_minutes = (settings || {})["buffer_minutes"].presence&.to_i || 0

  def buffer_minutes=(value)
    @raw_buffer_minutes = value
    self.settings = (settings || {}).merge("buffer_minutes" => value.to_s.match?(/\A\d+\z/) ? value.to_i : value)
  end

  def offers?(treatment) = treatment_ids.include?(treatment.id)

  # The practitioner's working windows on a date, earliest first.
  def windows_on(date) = availability_windows.select { _1.weekday == date.wday }.sort_by(&:starts_at_minute)

  def first_name = name.split.first

  def buffer_in_range
    raw = (settings || {})["buffer_minutes"]
    return if raw.nil? || (raw.to_s.match?(/\A\d+\z/) && raw.to_i.between?(0, 60))

    errors.add(:buffer_minutes, "must be in 0..60")
  end

  def as_api
    { id: id, name: name, specialty: specialty, buffer_minutes: buffer_minutes, location: location.name, treatments: treatments.map(&:code).sort }
  end
end
