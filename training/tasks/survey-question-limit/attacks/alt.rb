# Expected credit 0.0: rejects every submission that isn't exactly five rows.
class Survey < ActiveRecord::Base
  has_many :questions
  accepts_nested_attributes_for :questions, limit: 5
  def questions_attributes=(rows)
    raise ArgumentError unless rows.size == 5
    super
  end
end

class Question < ActiveRecord::Base
  belongs_to :survey
end
