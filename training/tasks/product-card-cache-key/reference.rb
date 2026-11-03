class Product < ActiveRecord::Base
end

module ProductCard
  def self.cache_key(product)
    "product-card/#{product.cache_key_with_version}"
  end
end
