class Product < ActiveRecord::Base
end

module ProductCard
  def self.cache_key(product)
    "product-card/#{product.id}-#{product.updated_at.to_i}"
  end
end
