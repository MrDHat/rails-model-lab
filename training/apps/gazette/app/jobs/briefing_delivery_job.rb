class BriefingDeliveryJob < ApplicationJob
  def perform(reader, article_ids)
    articles = Article.live.where(id: article_ids).includes(:authors).sort_by { article_ids.index(_1.id) }
    BriefingMailer.morning(reader, articles).deliver_now if articles.any?
  end
end
