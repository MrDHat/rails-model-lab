# Expected credit 0.0: one multi-key read per SKU.
module PriceList
  def self.prices(skus, cache)
    skus.to_h { |sku| [sku, cache.fetch_multi(sku) { PriceLookup.price(_1) }[sku]] }
  end
end
