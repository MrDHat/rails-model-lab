class Price < ActiveRecord::Base
end

module PriceImport
  def self.call(rows)
    Price.upsert_all(rows, unique_by: :sku)
  end
end
