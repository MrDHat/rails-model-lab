class Story < ActiveRecord::Base
  def record_view!
    self.class.increment_counter(:views, id)
  end
end
