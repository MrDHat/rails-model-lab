require 'minitest/autorun'
require_relative 'setup'

class EntryLabelsApiTest < Minitest::Test
  def test_through_association
    assert_equal :labelings, Entry.reflect_on_association(:labels)&.options&.dig(:through)
  end
end
