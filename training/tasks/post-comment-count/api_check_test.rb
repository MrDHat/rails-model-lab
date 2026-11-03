require 'minitest/autorun'
require_relative 'setup'

class CommentCountApiTest < Minitest::Test
  def test_counter_cache_is_declared
    assert Comment.reflect_on_association(:article).options[:counter_cache]
  end
end
