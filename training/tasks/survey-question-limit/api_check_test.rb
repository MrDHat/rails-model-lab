require 'minitest/autorun'
require_relative 'setup'

class SurveyLimitApiTest < Minitest::Test
  def test_limit_is_declared
    assert_equal 5, Survey.nested_attributes_options.fetch(:questions)[:limit]
  end
end
