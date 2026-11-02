# Expected credit 0.0: waits 30 seconds once, then 1 second.
class SyncJob < ActiveJob::Base
  retry_on Timeout::Error, wait: ->(executions) { executions == 1 ? 30.seconds : 1.second }, attempts: 3

  def perform
    Remote.fetch
  end
end
