class CommentMailer < ApplicationMailer
  def awaiting_moderation(comment)
    @comment = comment
    @article = comment.article
    mail to: @article.authors.map(&:email), subject: "New comment on \"#{@article.headline}\""
  end
end
