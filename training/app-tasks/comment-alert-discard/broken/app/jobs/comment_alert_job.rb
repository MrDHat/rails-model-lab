# Tells a story's authors that a reader comment is waiting for moderation.
class CommentAlertJob < ApplicationJob
  def perform(comment)
    return unless comment.pending?

    CommentMailer.awaiting_moderation(comment).deliver_now if comment.article.authors.any?
  rescue ActiveRecord::RecordNotFound
    # The comment was deleted before the job ran.
  end
end
