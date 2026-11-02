class DigestJob < ActiveJob::Base
  def perform(user_id); end
end

module Digest
  def self.send_all(user_ids)
    user_ids.each { DigestJob.perform_later(_1) }
  end
end
