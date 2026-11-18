# The morning briefing email: the most-read stories of the last day, sent to
# every reader who opted in. BriefingJob runs it at 6am.
class MorningBriefing
  def self.deliver(now = Time.current) = new(now).deliver

  def initialize(now = Time.current)
    @now = now
  end

  def top_stories
    Article.live
      .where(published_at: (@now - 24.hours)..@now)
      .order(views_count: :desc, published_at: :desc)
      .limit(Setting[:briefing_size])
  end

  # Returns how many readers it queued a briefing for.
  def deliver
    article_ids = top_stories.ids
    return 0 if article_ids.empty?

    queued = 0
    Reader.briefing.find_each do |reader|
      BriefingDeliveryJob.perform_later(reader, article_ids)
      queued += 1
    end
    queued
  end
end
