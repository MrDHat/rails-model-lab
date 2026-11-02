class Story < ActiveRecord::Base
  def record_view!
    update!(views: views + 1)
  end
end
