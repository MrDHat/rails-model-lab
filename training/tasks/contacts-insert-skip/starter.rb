class Lead < ActiveRecord::Base
end

module LeadImport
  def self.call(rows)
    rows.each { Lead.create!(_1) }
  end
end
