# Expected credit 0.0: enum with the wrong stored codes.
class Todo < ActiveRecord::Base
  enum :state, { todo: 7, doing: 8, done: 2 }
end
