class Page < ActiveRecord::Base
  self.locking_column = :revision
end
