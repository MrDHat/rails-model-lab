module ApplicationHelper
  def dateline(time)
    return "" unless time

    time.in_time_zone.strftime("%-d %B %Y, %-l:%M%P")
  end

  def status_label(article)
    article.ready? && article.publish_at ? "scheduled for #{dateline(article.publish_at)}" : article.status
  end
end
