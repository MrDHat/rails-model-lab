# Site-wide settings the chief editor changes from the newsroom.
class Setting < ApplicationRecord
  DEFAULTS = { "comments_open" => true, "briefing_size" => 5, "front_page_order" => [] }.freeze

  validates :key, presence: true, uniqueness: true

  def self.[](key)
    key = key.to_s
    setting = find_by(key: key)
    setting ? setting.value : DEFAULTS[key]
  end

  def self.[]=(key, value)
    find_or_initialize_by(key: key.to_s).update!(value: value)
  end
end
