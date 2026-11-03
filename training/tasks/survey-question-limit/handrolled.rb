class Survey < ActiveRecord::Base
  has_many :questions
  accepts_nested_attributes_for :questions

  def questions_attributes=(rows)
    raise ArgumentError, 'too many questions' if rows.size > 5
    super
  end
end

class Question < ActiveRecord::Base
  belongs_to :survey
end
