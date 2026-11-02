module PriceWidget
  def self.render(sku)
    PriceFeed.price_for(sku)
  rescue StandardError => e
    ActiveSupport.error_reporter.report(e, handled: true)
    'Price unavailable'
  end
end
