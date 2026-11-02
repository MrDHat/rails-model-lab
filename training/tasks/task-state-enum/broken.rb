class Todo < ActiveRecord::Base
  enum :state, { todo: 'todo', doing: 'doing', done: 'done' }
end
