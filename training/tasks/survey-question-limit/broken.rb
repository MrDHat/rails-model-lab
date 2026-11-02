class Survey < ActiveRecord::Base
  has_many :questions
  accepts_nested_attributes_for :questions, limit: 6
end

class Question < ActiveRecord::Base
  belongs_to :survey
end
