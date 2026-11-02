# Expected credit 1.0: left join with an IS NULL check, the join where.missing builds.
class Agent < ActiveRecord::Base
end

class SupportCase < ActiveRecord::Base
  self.table_name = 'cases'
  belongs_to :agent, optional: true

  scope :unassigned, -> { left_joins(:agent).where(agents: { id: nil }) }
end

if false
  missing
end
