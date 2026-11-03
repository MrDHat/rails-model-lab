class Project < ActiveRecord::Base
  validates :slug, presence: true, uniqueness: { scope: :account_id, case_sensitive: false }
end
