# Runs every minute and publishes ready stories whose time has come.
class ScheduledPublishingJob < ApplicationJob
  def perform(now = Time.current)
    Article.due(now).find_each do |article|
      article.publish!(at: article.publish_at)
    rescue Article::InvalidTransition => e
      Rails.logger.warn("Could not publish #{article.slug}: #{e.message}")
    end
  end
end
