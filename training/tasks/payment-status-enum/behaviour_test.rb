require 'minitest/autorun'
require_relative 'setup'

class PaymentStatusTest < Minitest::Test
  def test_default_is_pending
    row = Payment.new
    assert row.valid?
    assert row.status_pending?
  end

  def test_explicit_legacy_codes_are_preserved
    assert_equal({ 'pending' => 0, 'settled' => 10, 'failed' => 20 }, Payment.statuses)
  end

  def test_persisted_legacy_code_reads_correctly
    id = Payment.create!.id
    Payment.where(id: id).update_all(status: 10)
    row = Payment.find(id)
    assert_equal 'settled', row.status
    assert row.status_settled?
  end

  def test_failed_predicate_and_storage
    row = Payment.create!(status: :failed).reload
    assert row.status_failed?
    assert_equal 20, row.status_for_database
  end

  def test_unknown_string_does_not_raise_on_assignment
    row = Payment.new
    row.status = 'unexpected'
    refute row.valid?
    assert row.errors[:status].any?
  end

  def test_explicit_nil_is_invalid
    row = Payment.new(status: nil)
    refute row.valid?
    assert row.errors[:status].any?
  end
end
