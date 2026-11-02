class Shirt < ActiveRecord::Base
  class SizeType < ActiveRecord::Type::String
    CODES = { 'small' => 's', 'medium' => 'm', 'large' => 'l' }.freeze

    def cast(value) = value.nil? ? nil : (CODES.key(value.to_s) || value.to_s)
    def serialize(value) = CODES[cast(value)]
    def deserialize(value) = CODES.key(value)
  end

  attribute :size, SizeType.new
end
