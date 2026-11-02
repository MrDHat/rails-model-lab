require 'minitest/autorun'
require_relative 'setup'

class AccountStatesTest < Minitest::Test
  def test_both_fields_have_predicates
    row = Account.create!(status: :archived, billing_state: :past_due).reload
    assert row.status_archived?
    refute row.status_active?
    assert row.billing_past_due?
    refute row.billing_active?
  end

  def test_codes_are_kept
    row = Account.create!(status: :archived, billing_state: :past_due)
    codes = Account.connection.select_rows("SELECT status, billing_state FROM accounts WHERE id = #{row.id}")
    assert_equal [[1, 1]], codes
  end
end
