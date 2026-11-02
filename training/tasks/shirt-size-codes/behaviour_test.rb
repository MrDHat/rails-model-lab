require 'minitest/autorun'
require_relative 'setup'

class ShirtSizeTest < Minitest::Test
  def setup
    Shirt.delete_all
  end

  def stored(shirt)
    Shirt.connection.select_value("SELECT size FROM shirts WHERE id = #{shirt.id}")
  end

  def test_names_map_to_codes
    shirt = Shirt.create!(size: :large)
    assert_equal 'l', stored(shirt)
    assert_equal 'large', Shirt.find(shirt.id).size
    assert Shirt.find(shirt.id).large?
    refute Shirt.find(shirt.id).small?
  end

  def test_scope_finds_by_name
    Shirt.create!(size: :small)
    medium = Shirt.create!(size: :medium)
    assert_equal [medium.id], Shirt.medium.pluck(:id)
  end
end
