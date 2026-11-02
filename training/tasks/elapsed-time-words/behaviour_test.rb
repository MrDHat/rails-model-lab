require 'minitest/autorun'
require_relative 'setup'

class ElapsedTest < Minitest::Test
  def test_examples
    {
      7500 => '2 hours and 5 minutes',
      3661 => '1 hour, 1 minute, and 1 second',
      90_000 => '1 day and 1 hour',
      60 => '1 minute',
      0 => '0 seconds'
    }.each { |seconds, words| assert_equal words, Elapsed.describe(seconds) }
  end
end
