class Project < ActiveRecord::Base
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
end
