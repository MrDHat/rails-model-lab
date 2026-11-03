class ApiClient < ApplicationRecord
  validates :name, :token, presence: true
end
