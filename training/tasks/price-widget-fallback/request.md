PriceWidget.render(sku) shows PriceFeed.price_for(sku). When the feed raises
any StandardError, show "Price unavailable" instead of failing the page, and
report the error as handled to the app's error reporter
(ActiveSupport.error_reporter) so our error tracker sees it.
