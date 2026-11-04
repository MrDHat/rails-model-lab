class Category < ApplicationRecord
  has_many :tools, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
end
