class Team < ApplicationRecord
  has_many :tickets
  validates :name, presence: true
end
