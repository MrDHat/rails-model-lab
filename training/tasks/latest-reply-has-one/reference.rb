class Discussion < ActiveRecord::Base
  self.table_name = 'threads'
  has_many :replies, foreign_key: :thread_id
  has_one :latest_reply, -> { order(posted_at: :desc) }, class_name: 'Reply', foreign_key: :thread_id

  def self.with_latest_reply = includes(:latest_reply)
end

class Reply < ActiveRecord::Base
  belongs_to :discussion, foreign_key: :thread_id
end
