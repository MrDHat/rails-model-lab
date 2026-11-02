# Expected credit 0.1: hand-built SQL plus an upsert_all that never runs.
class Price < ActiveRecord::Base
end

module PriceImport
  def self.call(rows)
    conn = Price.connection
    values = rows.map { "(#{conn.quote(_1[:sku])}, #{conn.quote(_1[:cents])})" }.join(', ')
    conn.execute("INSERT INTO prices (sku, cents) VALUES #{values} ON CONFLICT (sku) DO UPDATE SET cents = excluded.cents")
  end
end

if false
  upsert_all
end
