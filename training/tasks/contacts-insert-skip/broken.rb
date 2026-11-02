class Lead < ActiveRecord::Base
end

module LeadImport
  def self.call(rows)
    Lead.upsert_all(rows, unique_by: :email)
  end
end
