require 'minitest/autorun'
require_relative 'setup'

class CategoryRestrictTest < Minitest::Test
  def test_category_with_products_is_kept
    category = Category.create!(name: 'Tools')
    category.products.create!
    refute category.destroy
    assert category.errors[:base].any?
    assert Category.exists?(category.id)
    assert_equal 1, category.products.count
  end

  def test_empty_category_deletes
    category = Category.create!(name: 'Empty')
    assert category.destroy
    refute Category.exists?(category.id)
  end
end
