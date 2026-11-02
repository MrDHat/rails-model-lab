require 'minitest/autorun'
require_relative 'setup'

class RouteNestedStopsApiTest < Minitest::Test
  def test_uses_built_in_blank_rejection_and_destroy
    options = DeliveryRoute.nested_attributes_options.fetch(:stops)
    assert_same ActiveRecord::NestedAttributes::ClassMethods::REJECT_ALL_BLANK_PROC, options[:reject_if]
    assert options[:allow_destroy]
  end
end
