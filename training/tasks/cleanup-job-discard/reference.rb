class Upload < ActiveRecord::Base
end

class CleanupJob < ActiveJob::Base
  discard_on ActiveRecord::RecordNotFound

  def perform(upload_id)
    Upload.find(upload_id).update!(cleaned: true)
  end
end
