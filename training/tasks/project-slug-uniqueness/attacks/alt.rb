# Expected credit 0.0: uniqueness without the account scope.
class Project < ActiveRecord::Base
  validates :slug,  uniqueness: { scope: :account_id, case_sensitive: false }
end
