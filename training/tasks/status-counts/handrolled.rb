class Job < ActiveRecord::Base
  def self.status_counts
    connection.select_rows('SELECT status, COUNT(*) FROM jobs GROUP BY status').to_h
  end
end
