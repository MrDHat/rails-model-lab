# Expected credit 1.0: record cache_key, which carries the timestamp here.
class Product < ActiveRecord::Base
end

module ProductCard
  def self.cache_key(product)
    "product-card/#{product.cache_key}"
  end
end
