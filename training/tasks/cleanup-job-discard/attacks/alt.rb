# Expected credit 0.1: rescue_from with an empty handler instead of discard_on.
class Upload < ActiveRecord::Base
end

class CleanupJob < ActiveJob::Base
  rescue_from(ActiveRecord::RecordNotFound) { nil }

  def perform(upload_id)
    Upload.find(upload_id).update!(cleaned: true)
  end
end
