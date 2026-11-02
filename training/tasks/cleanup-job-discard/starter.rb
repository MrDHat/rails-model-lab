class Upload < ActiveRecord::Base
end

class CleanupJob < ActiveJob::Base
  def perform(upload_id)
    Upload.find(upload_id).update!(cleaned: true)
  end
end
