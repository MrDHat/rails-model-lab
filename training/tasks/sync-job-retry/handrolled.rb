class SyncJob < ActiveJob::Base
  def perform
    Remote.fetch
  rescue Timeout::Error
    raise if executions >= 3
    retry_job(wait: 30.seconds)
  end
end
