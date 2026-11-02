module PriceWidget
  def self.render(sku)
    PriceFeed.price_for(sku)
  rescue StandardError
    'Price unavailable'
  end
end
