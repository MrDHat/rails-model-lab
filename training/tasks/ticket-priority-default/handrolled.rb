class Ticket < ActiveRecord::Base
  after_initialize :default_priority

  private

  def default_priority
    self.priority = 3 if new_record? && priority.nil?
  end
end
