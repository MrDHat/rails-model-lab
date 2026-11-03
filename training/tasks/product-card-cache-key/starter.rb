class Product < ActiveRecord::Base
end

module ProductCard
  def self.cache_key(product)
    "product-card/#{product.id}"
  end
end
