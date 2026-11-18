# Removes a deleted reader's comments, one at a time so each story's comment
# count goes down with them.
class ReaderCommentsCleanupJob < ApplicationJob
  def perform(reader_id)
    Comment.where(reader_id: reader_id).find_each(&:destroy)
  end
end
