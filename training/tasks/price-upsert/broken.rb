class Price < ActiveRecord::Base
end

module PriceImport
  def self.call(rows)
    rows.each { Price.find_or_initialize_by(sku: _1[:sku]).update!(cents: _1[:cents]) }
  end
end
