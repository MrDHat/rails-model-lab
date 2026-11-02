class Shirt < ActiveRecord::Base
  SIZES = { 'small' => 's', 'medium' => 'm', 'large' => 'l' }.freeze

  SIZES.each do |name, code|
    scope name, -> { where(size: code) }
    define_method("#{name}?") { self[:size] == code }
  end

  def size
    SIZES.key(self[:size])
  end

  def size=(name)
    self[:size] = SIZES.fetch(name.to_s)
  end
end
