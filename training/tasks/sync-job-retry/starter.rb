class SyncJob < ActiveJob::Base
  def perform
    Remote.fetch
  end
end
