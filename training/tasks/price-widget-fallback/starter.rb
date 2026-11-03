module PriceWidget
  def self.render(sku)
    PriceFeed.price_for(sku)
  end
end
