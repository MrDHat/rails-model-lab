class DigestJob < ActiveJob::Base
  def perform(user_id); end
end

module Digest
  def self.send_all(user_ids)
    DigestJob.perform_later(user_ids)
  end
end
