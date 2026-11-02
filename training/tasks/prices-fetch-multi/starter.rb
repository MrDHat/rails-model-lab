module PriceList
  def self.prices(skus, cache)
    skus.to_h { [_1, PriceLookup.price(_1)] }
  end
end
