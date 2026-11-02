class Job < ActiveRecord::Base
  def self.status_counts
    all.group_by(&:status).transform_values(&:size)
  end
end
