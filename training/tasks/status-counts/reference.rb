class Job < ActiveRecord::Base
  def self.status_counts
    group(:status).count
  end
end
