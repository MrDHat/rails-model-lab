require 'minitest/autorun'
require_relative 'setup'

class ProductCardKeyTest < Minitest::Test
  def test_key_follows_the_record
    one = Product.create!(name: 'Mug')
    two = Product.create!(name: 'Cup')
    refute_equal ProductCard.cache_key(one), ProductCard.cache_key(two)
    before = ProductCard.cache_key(one)
    assert_equal before, ProductCard.cache_key(Product.find(one.id))
    one.update!(name: 'Big mug')
    first_update = ProductCard.cache_key(one)
    one.update!(name: 'Huge mug')
    refute_equal before, first_update
    refute_equal first_update, ProductCard.cache_key(one)
  end
end
