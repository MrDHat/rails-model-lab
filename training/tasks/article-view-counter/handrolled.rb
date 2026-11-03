class Story < ActiveRecord::Base
  def record_view!
    self.class.where(id: id).update_all('views = views + 1')
  end
end
