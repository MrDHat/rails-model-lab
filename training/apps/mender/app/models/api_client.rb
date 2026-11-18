class ApiClient < ApplicationRecord
  validates :name, :token, presence: true
  validates :token, uniqueness: true
end
