class Entry < ActiveRecord::Base
  has_many :labelings

  def labels
    labelings.map(&:label)
  end
end

class Label < ActiveRecord::Base
end

class Labeling < ActiveRecord::Base
  belongs_to :entry
  belongs_to :label
end
