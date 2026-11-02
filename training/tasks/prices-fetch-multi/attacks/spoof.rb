# Expected credit 0.1: read_multi and write_multi plus a fetch_multi that never runs.
module PriceList
  def self.prices(skus, cache)
    found = cache.read_multi(*skus)
    missing = (skus - found.keys).to_h { [_1, PriceLookup.price(_1)] }
    cache.write_multi(missing) if missing.any?
    skus.to_h { |sku| [sku, found.fetch(sku) { missing[sku] }] }
  end
end

if false
  fetch_multi
end
