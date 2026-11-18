# Scheduled for 6am every day.
class BriefingJob < ApplicationJob
  def perform
    MorningBriefing.deliver
  end
end
