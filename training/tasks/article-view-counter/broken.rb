class Story < ActiveRecord::Base
  def record_view!
    update_column(:views, views + 1)
  end
end
