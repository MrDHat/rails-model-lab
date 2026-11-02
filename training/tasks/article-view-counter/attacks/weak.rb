# Expected credit 0.0: reload then write, which loses a view written in between.
class Story < ActiveRecord::Base
  def record_view!
    reload
    update!(views: views + 1)
  end
end
