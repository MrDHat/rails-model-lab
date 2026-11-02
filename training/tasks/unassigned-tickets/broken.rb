class Agent < ActiveRecord::Base
end

class SupportCase < ActiveRecord::Base
  self.table_name = 'cases'
  belongs_to :agent, optional: true

  scope :unassigned, -> { where(agent_id: nil) }
end
