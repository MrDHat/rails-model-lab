PriceList.prices(skus, cache) returns a hash of sku => price for a list page.
Prices come from PriceLookup.price(sku), which is slow, so cache each price
in the given cache store. Only look up SKUs that aren't cached. Pages show
hundreds of SKUs, so read the cache in one multi-key read, never one read per
SKU.
