module PriceList
  def self.prices(skus, cache)
    skus.to_h { |sku| [sku, cache.fetch(sku) { PriceLookup.price(sku) }] }
  end
end
