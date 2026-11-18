# Tells a story's authors that a reader comment is waiting for moderation.
class CommentAlertJob < ApplicationJob
  # The comment was deleted (usually as spam) before the job ran.
  discard_on ActiveJob::DeserializationError

  def perform(comment)
    return unless comment.pending?

    CommentMailer.awaiting_moderation(comment).deliver_now if comment.article.authors.any?
  end
end
