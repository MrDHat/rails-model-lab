class Discussion < ActiveRecord::Base
  self.table_name = 'threads'
  has_many :replies, foreign_key: :thread_id
end

class Reply < ActiveRecord::Base
  belongs_to :discussion, foreign_key: :thread_id
end
