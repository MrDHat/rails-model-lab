class Agent < ActiveRecord::Base
end

class SupportCase < ActiveRecord::Base
  self.table_name = 'cases'
  belongs_to :agent, optional: true

  scope :unassigned, -> { where('agent_id IS NULL OR agent_id NOT IN (SELECT id FROM agents)') }
end
