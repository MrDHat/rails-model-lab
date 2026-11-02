class Project < ActiveRecord::Base
  validates :slug, presence: true
end
