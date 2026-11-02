require 'minitest/autorun'
require_relative 'setup'

class ReservationDatesApiTest < Minitest::Test
  def test_return_date_uses_comparison_validator
    assert Reservation.validators_on(:return_on).grep(ActiveModel::Validations::ComparisonValidator).any?
  end
end
