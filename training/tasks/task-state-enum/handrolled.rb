class Todo < ActiveRecord::Base
  STATES = { 'todo' => 0, 'doing' => 1, 'done' => 2 }.freeze

  scope :done, -> { where(state: 2) }
  scope :not_done, -> { where.not(state: 2) }

  def state
    STATES.key(self[:state])
  end

  def state=(name)
    self[:state] = STATES.fetch(name.to_s)
  end

  def done? = state == 'done'

  def done!
    update!(state: 'done')
  end
end
