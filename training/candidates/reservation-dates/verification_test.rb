require 'active_record'
require 'active_support/all'
require 'minitest/autorun'
require 'bigdecimal'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :reservations do |t|
    t.date :pickup_on
    t.date :return_on
  end
end

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)

class ReservationDatesTest < Minitest::Test
  def test_accepts_a_later_return_date_and_persists_dates
    row = Reservation.create!(pickup_on: '2026-06-10', return_on: '2026-06-12')
    assert_equal Date.new(2026, 6, 12), row.reload.return_on
  end

  def test_rejects_same_day
    row = Reservation.new(pickup_on: '2026-06-10', return_on: '2026-06-10')
    refute row.valid?
    assert row.errors.of_kind?(:return_on, :greater_than) || row.errors[:return_on].any?
  end

  def test_rejects_reversed_dates
    refute Reservation.new(pickup_on: '2026-06-10', return_on: '2026-06-09').valid?
  end

  def test_missing_pickup_does_not_raise
    row = Reservation.new(return_on: '2026-06-12')
    refute row.valid?
    assert row.errors[:pickup_on].any?
  end

  def test_missing_return_does_not_raise
    row = Reservation.new(pickup_on: '2026-06-10')
    refute row.valid?
    assert row.errors[:return_on].any?
  end

  def test_invalid_date_text_is_a_validation_error
    refute Reservation.new(pickup_on: 'not-a-date', return_on: '2026-06-12').valid?
  end

  def test_invalid_update_preserves_persisted_dates
    row = Reservation.create!(pickup_on: '2026-06-10', return_on: '2026-06-12')
    refute row.update(return_on: '2026-06-08')
    assert_equal Date.new(2026, 6, 12), row.reload.return_on
    refute row.update(pickup_on: '2026-06-13')
  end
end
