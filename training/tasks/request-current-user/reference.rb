class Current < ActiveSupport::CurrentAttributes
  attribute :user
end

class Note < ActiveRecord::Base
  before_create { self.author ||= Current.user }
end
