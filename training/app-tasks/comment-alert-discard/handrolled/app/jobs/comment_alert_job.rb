# Tells a story's authors that a reader comment is waiting for moderation.
class CommentAlertJob < ApplicationJob
  # Takes the comment's id: the comment may be deleted (usually as spam)
  # before the job runs.
  def perform(comment_id)
    comment = Comment.find_by(id: comment_id)
    return unless comment&.pending?

    CommentMailer.awaiting_moderation(comment).deliver_now if comment.article.authors.any?
  end
end
