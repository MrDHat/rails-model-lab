require 'minitest/autorun'
require_relative 'setup'

class CategoryRestrictApiTest < Minitest::Test
  def test_dependent_option
    assert_equal :restrict_with_error, Category.reflect_on_association(:products).options[:dependent]
  end
end
