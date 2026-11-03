require 'minitest/autorun'
require_relative 'setup'

class AccountStatesTest < Minitest::Test
  def setup
    Account.delete_all
  end

  def codes(row)
    Account.connection.select_rows("SELECT status, billing_state FROM accounts WHERE id = #{row.id}").first
  end

  def test_names_read_back
    row = Account.create!(status: :archived, billing_state: :past_due).reload
    assert_equal %w[archived past_due], [row.status, row.billing_state]
    row = Account.create!(status: :active, billing_state: :active).reload
    assert_equal %w[active active], [row.status, row.billing_state]
  end

  def test_codes_are_kept
    assert_equal [1, 1], codes(Account.create!(status: :archived, billing_state: :past_due))
    assert_equal [0, 0], codes(Account.create!(status: :active, billing_state: :active))
    assert_equal [0, 1], codes(Account.create!(status: :active, billing_state: :past_due))
  end

  def test_query_by_name
    late = Account.create!(status: :active, billing_state: :past_due)
    Account.create!(status: :archived, billing_state: :active)
    assert_equal [late.id], Account.where(billing_state: :past_due).pluck(:id)
    assert_equal [late.id], Account.where(status: :active).pluck(:id)
  end
end
