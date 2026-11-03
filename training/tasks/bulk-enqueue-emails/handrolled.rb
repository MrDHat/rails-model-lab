class DigestJob < ActiveJob::Base
  def perform(user_id); end
end

module Digest
  def self.send_all(user_ids)
    DigestJob.queue_adapter.enqueue_all(user_ids.map { DigestJob.new(_1) })
  end
end
