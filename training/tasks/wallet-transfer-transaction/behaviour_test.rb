require 'minitest/autorun'
require_relative 'setup'

class TransferTest < Minitest::Test
  def test_successful_transfer
    from = Wallet.create!(cents: 1_000)
    to = Wallet.create!(cents: 0)
    Transfer.call(from, to, 300)
    assert_equal [700, 300], [from.reload.cents, to.reload.cents]
  end

  def test_failed_credit_rolls_back
    from = Wallet.create!(cents: 1_000)
    to = Wallet.create!(cents: 0, frozen_account: true)
    assert_raises(ActiveRecord::RecordInvalid) { Transfer.call(from, to, 300) }
    assert_equal [1_000, 0], [Wallet.find(from.id).cents, Wallet.find(to.id).cents]
  end
end
