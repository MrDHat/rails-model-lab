class Product < ActiveRecord::Base
end

module ProductCard
  def self.cache_key(product)
    "product-card/#{product.id}-#{product.updated_at.strftime('%Y%m%d%H%M%S%6N')}"
  end
end
