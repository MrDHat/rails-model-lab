# Expected credit 0.1: manual rescue and report plus a handle call that never runs.
module PriceWidget
  def self.render(sku)
    PriceFeed.price_for(sku)
  rescue StandardError => e
    ActiveSupport.error_reporter.report(e, handled: true)
    'Price unavailable'
  end
end

if false
  handle
end
