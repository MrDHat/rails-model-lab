class Todo < ActiveRecord::Base
  enum :state, { todo: 0, doing: 1, done: 2 }, scopes: false
end
