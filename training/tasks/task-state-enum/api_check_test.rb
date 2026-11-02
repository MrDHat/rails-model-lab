require 'minitest/autorun'
require_relative 'setup'

class TodoStateApiTest < Minitest::Test
  def test_state_is_an_enum
    assert Todo.defined_enums.key?('state')
  end
end
