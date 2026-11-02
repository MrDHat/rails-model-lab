require 'minitest/autorun'
require_relative 'setup'

class BookListTest < Minitest::Test
  def test_lines_in_two_queries
    herbert = Writer.create!(name: 'Frank Herbert')
    le_guin = Writer.create!(name: 'Ursula K. Le Guin')
    Book.create!(title: 'Dune', writer: herbert)
    Book.create!(title: 'Earthsea', writer: le_guin)
    Book.create!(title: 'Children of Dune', writer: herbert)
    queries = 0
    counter = ->(*, payload) { queries += 1 unless payload[:name] == 'SCHEMA' }
    lines = ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { BookList.lines }
    assert_equal ['Children of Dune by Frank Herbert', 'Dune by Frank Herbert', 'Earthsea by Ursula K. Le Guin'], lines
    assert_operator queries, :<=, 2
  end
end
