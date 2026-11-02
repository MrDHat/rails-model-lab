module PriceList
  def self.prices(skus, cache)
    cache.fetch_multi(*skus) { PriceLookup.price(_1) }
  end
end
