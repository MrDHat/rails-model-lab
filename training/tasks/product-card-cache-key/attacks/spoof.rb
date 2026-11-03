# Expected credit 0.1: manual key plus a cache_key call that never runs.
class Product < ActiveRecord::Base
end

module ProductCard
  def self.cache_key(product)
    "product-card/#{product.id}-#{product.updated_at.strftime('%Y%m%d%H%M%S%6N')}"
  end
end

if false
  cache_key_with_version
end
