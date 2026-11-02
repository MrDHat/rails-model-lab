class DigestJob < ActiveJob::Base
  def perform(user_id); end
end

module Digest
  def self.send_all(user_ids)
    ActiveJob.perform_all_later(user_ids.map { DigestJob.new(_1) })
  end
end
