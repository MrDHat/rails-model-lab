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
    { small: 's', medium: 'm', large: 'l' }.each do |name, code|
      shirt = Shirt.create!(size: name)
      assert_equal code, stored(shirt)
      assert_equal name.to_s, Shirt.find(shirt.id).size
    end
  end

  def test_query_by_name
    Shirt.create!(size: :small)
    medium = Shirt.create!(size: :medium)
    assert_equal [medium.id], Shirt.where(size: :medium).pluck(:id)
    assert_equal [medium.id], Shirt.where(size: 'medium').pluck(:id)
  end
end
