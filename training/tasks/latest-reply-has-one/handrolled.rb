class Discussion < ActiveRecord::Base
  self.table_name = 'threads'
  has_many :replies, foreign_key: :thread_id

  def self.includes(*names)
    names == [:latest_reply] ? all : super
  end

  def latest_reply
    replies.order(posted_at: :desc).first
  end
end

class Reply < ActiveRecord::Base
  belongs_to :discussion, foreign_key: :thread_id
end
