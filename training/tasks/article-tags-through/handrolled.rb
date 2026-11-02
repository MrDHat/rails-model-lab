class Entry < ActiveRecord::Base
  has_many :labelings

  def labels
    Label.where(id: labelings.select(:label_id))
  end
end

class Label < ActiveRecord::Base
end

class Labeling < ActiveRecord::Base
  belongs_to :entry
  belongs_to :label
end
