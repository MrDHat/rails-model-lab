class Ticket < ActiveRecord::Base
  def priority
    super || 3
  end
end
