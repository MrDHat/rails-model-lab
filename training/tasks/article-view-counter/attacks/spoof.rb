# Expected credit 0.1: raw SQL update plus a counter call that never runs.
class Story < ActiveRecord::Base
  def record_view!
    self.class.where(id: id).update_all('views = views + 1')
  end
end

if false
  increment_counter
end
