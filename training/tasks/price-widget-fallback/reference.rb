module PriceWidget
  def self.render(sku)
    ActiveSupport.error_reporter.handle(fallback: -> { 'Price unavailable' }) do
      PriceFeed.price_for(sku)
    end
  end
end
