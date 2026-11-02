require 'minitest/autorun'
require_relative 'setup'

class CardTouchTest < Minitest::Test
  OLD = Time.utc(2020, 1, 1)

  def setup
    @board = Board.create!
    @card = @board.cards.create!(title: 'A')
    @board.update_column(:updated_at, OLD)
  end

  def test_update_bumps_board
    @card.update!(title: 'B')
    assert_operator @board.reload.updated_at, :>, OLD
  end

  def test_destroy_bumps_board
    @card.destroy
    assert_operator @board.reload.updated_at, :>, OLD
  end

  def test_create_bumps_board
    @board.cards.create!(title: 'C')
    assert_operator @board.reload.updated_at, :>, OLD
  end
end
