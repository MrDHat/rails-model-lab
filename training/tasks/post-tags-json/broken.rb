class Post < ActiveRecord::Base
  serialize :tags, coder: YAML, type: Array
end
