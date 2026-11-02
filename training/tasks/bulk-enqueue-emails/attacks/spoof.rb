# Expected credit 0.0: one perform_later per user plus a bulk call that never runs.
class DigestJob < ActiveJob::Base
  def perform(user_id); end
end

module Digest
  def self.send_all(user_ids)
    user_ids.each { DigestJob.perform_later(_1) }
  end
end

if false
  perform_all_later
end
