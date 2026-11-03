# Expected credit 0.0: JSON type that reads a NULL column as nil.
class Post < ActiveRecord::Base
  attribute :tags, :json, default: -> { [] }
end
