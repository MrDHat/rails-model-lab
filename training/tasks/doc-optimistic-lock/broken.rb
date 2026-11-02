class Page < ActiveRecord::Base
  before_update { self.revision += 1 }
end
