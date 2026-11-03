class Category < ApplicationRecord
  has_many :tools, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
