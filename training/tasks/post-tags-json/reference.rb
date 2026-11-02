class Post < ActiveRecord::Base
  serialize :tags, coder: JSON, type: Array
end
