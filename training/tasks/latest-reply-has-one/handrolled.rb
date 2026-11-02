class Discussion < ActiveRecord::Base
  self.table_name = 'threads'
  has_many :replies, foreign_key: :thread_id

  def self.with_latest_reply
    threads = all.to_a
    newest = Reply.where(thread_id: threads.map(&:id)).order(:posted_at).index_by(&:thread_id)
    threads.each { _1.instance_variable_set(:@latest_reply, newest[_1.id]) }
  end

  def latest_reply
    return @latest_reply if defined?(@latest_reply)
    replies.order(posted_at: :desc).first
  end
end

class Reply < ActiveRecord::Base
  belongs_to :discussion, foreign_key: :thread_id
end
