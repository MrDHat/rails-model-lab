# Expected credit 1.0: unused extra code next to a correct answer.
class Page < ActiveRecord::Base
  self.locking_column = :revision
end
class Page
  def _update_record(*args)
    super
  rescue ActiveRecord::StaleObjectError
    raise
  end
end
