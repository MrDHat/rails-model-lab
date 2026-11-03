# Expected credit 0.0: length check instead of presence, so whitespace passes.
class Project < ActiveRecord::Base
  validates :slug, length: { minimum: 1 }, uniqueness: { scope: :account_id, case_sensitive: false }
end
