class NormalizedEmail < ActiveModel::Type::String
  def cast(value)
    super(value&.strip&.downcase)
  end

  def serialize(value)
    super(cast(value))
  end
end

class Contact < ActiveRecord::Base
  attribute :email, NormalizedEmail.new
  validates :email, presence: true
end
