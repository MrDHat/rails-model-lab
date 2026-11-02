# Expected credit 0.0: sets the default only when saving.
class Ticket < ActiveRecord::Base
  before_create { self.priority = 3 if priority.nil? }
end
