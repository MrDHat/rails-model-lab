class SyncJob < ActiveJob::Base
  retry_on Timeout::Error, wait: 30.seconds, attempts: 3

  def perform
    Remote.fetch
  end
end
