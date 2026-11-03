require 'minitest/autorun'
require_relative 'setup'

class TicketPriorityApiTest < Minitest::Test
  def test_default_is_declared_on_the_attribute
    assert_equal 3, Ticket.column_defaults['priority']
  end
end
