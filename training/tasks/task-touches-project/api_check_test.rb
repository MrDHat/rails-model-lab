require 'minitest/autorun'
require_relative 'setup'

class CardTouchApiTest < Minitest::Test
  def test_touch_is_declared
    assert Card.reflect_on_association(:board).options[:touch]
  end
end
