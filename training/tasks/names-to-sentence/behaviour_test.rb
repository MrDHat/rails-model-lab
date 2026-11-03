require 'minitest/autorun'
require_relative 'setup'

class AttendeesTest < Minitest::Test
  def test_examples
    assert_equal '', Attendees.summary([])
    assert_equal 'Ana', Attendees.summary(%w[Ana])
    assert_equal 'Ana and Bo', Attendees.summary(%w[Ana Bo])
    assert_equal 'Ana, Bo, and Cy', Attendees.summary(%w[Ana Bo Cy])
  end
end
