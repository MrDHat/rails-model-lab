class SyncJob < ActiveJob::Base
  retry_on Timeout::Error

  def perform
    Remote.fetch
  end
end
