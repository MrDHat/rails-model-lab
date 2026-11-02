class Agent < ActiveRecord::Base
end

class SupportCase < ActiveRecord::Base
  self.table_name = 'cases'
  belongs_to :agent, optional: true

  scope :unassigned, -> { left_joins(:agent).where(agents: { id: nil }) }
end
