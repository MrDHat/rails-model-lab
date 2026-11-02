class Discussion < ActiveRecord::Base
  self.table_name = 'threads'
  has_many :replies, foreign_key: :thread_id

  def self.with_latest_reply = includes(:replies)

  def latest_reply
    replies.loaded? ? replies.max_by(&:posted_at) : replies.order(posted_at: :desc).first
  end
end

class Reply < ActiveRecord::Base
  belongs_to :discussion, foreign_key: :thread_id
end
