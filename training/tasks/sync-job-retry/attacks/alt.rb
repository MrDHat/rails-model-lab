# Expected credit 0.0: retries on every error.
class SyncJob < ActiveJob::Base
  rescue_from(Timeout::Error) { nil }
  def perform
    Remote.fetch
  rescue Timeout::Error
    raise if executions >= 3
    retry_job(wait: 30.seconds)
  end
end
