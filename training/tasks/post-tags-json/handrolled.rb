class Post < ActiveRecord::Base
  def tags
    JSON.parse(self[:tags] || '[]')
  end

  def tags=(list)
    self[:tags] = JSON.generate(list)
  end
end
