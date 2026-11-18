# Removes a deleted reader's comments.
class ReaderCommentsCleanupJob < ApplicationJob
  def perform(reader_id)
    Comment.where(reader_id: reader_id).delete_all
  end
end
