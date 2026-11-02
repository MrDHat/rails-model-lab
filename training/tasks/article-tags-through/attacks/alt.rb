# Expected credit 0.0: declares the association but returns every entry's labels.
class Entry < ActiveRecord::Base
  has_many :labelings
  has_many :labels, through: :labelings
  def labels = Label.where(id: Labeling.select(:label_id))
end

class Label < ActiveRecord::Base
end

class Labeling < ActiveRecord::Base
  belongs_to :entry
  belongs_to :label
end
