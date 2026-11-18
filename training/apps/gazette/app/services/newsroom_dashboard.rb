# Counts and lists for the newsroom's start page.
class NewsroomDashboard
  def initialize(now = Time.current)
    @now = now
  end

  def drafts = Article.draft.where(wire_guid: nil).order(updated_at: :desc).limit(20)

  def wire_drafts = Article.draft.where.not(wire_guid: nil).order(created_at: :desc).limit(10)

  def scheduled = Article.ready.where.not(publish_at: nil).order(:publish_at)

  def pending_comments = Comment.pending.count

  def unread_letters = Letter.received.count

  def most_read_today
    Article.live.where(published_at: @now.beginning_of_day..@now).order(views_count: :desc).limit(5)
  end
end
