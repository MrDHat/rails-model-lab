class Entry < ActiveRecord::Base
  has_many :labelings
  has_many :labels, through: :labelings
end

class Label < ActiveRecord::Base
end

class Labeling < ActiveRecord::Base
  belongs_to :entry
  belongs_to :label
end
