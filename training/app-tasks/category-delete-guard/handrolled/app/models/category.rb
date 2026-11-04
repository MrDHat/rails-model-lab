class Category < ApplicationRecord
  has_many :tools

  before_destroy do
    if tools.exists?
      errors.add(:base, "Category still has tools")
      throw :abort
    end
  end

  validates :name, presence: true, uniqueness: true
end
