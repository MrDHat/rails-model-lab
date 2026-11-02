ProductCard.cache_key(product) returns the key for the cached product card
fragment. It must differ between products, stay the same while a product is
unchanged (including after reloading it), and change whenever the product is
updated, even twice within the same second. Keep the schema unchanged.
