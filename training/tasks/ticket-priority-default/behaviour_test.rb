require 'minitest/autorun'
require_relative 'setup'

class TicketPriorityTest < Minitest::Test
  def setup
    Ticket.delete_all
  end

  def test_new_ticket_defaults_and_persists
    id = Ticket.create!(title: 'Printer').id
    assert_equal 3, Ticket.find(id).priority
    assert_equal 1, Ticket.where(priority: 3).count
  end

  def test_given_priority_wins
    assert_equal 1, Ticket.create!(title: 'Fire', priority: 1).reload.priority
  end

  def test_old_rows_keep_nil
    Ticket.connection.execute("INSERT INTO tickets (title) VALUES ('old')")
    assert_nil Ticket.find_by(title: 'old').priority
  end
end
