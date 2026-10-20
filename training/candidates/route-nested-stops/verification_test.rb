require 'active_record'
require 'active_support/all'
require 'minitest/autorun'
require 'bigdecimal'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :delivery_routes do |t|
    t.string :name
  end
  create_table :stops do |t|
    t.references :delivery_route
    t.string :label
    t.string :notes
  end
end

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)

class RouteNestedStopsTest < Minitest::Test
  def setup
    Stop.delete_all
    DeliveryRoute.delete_all
  end

  def test_empty_rows_are_ignored
    route = DeliveryRoute.create!(name: 'North', stops_attributes: [{}, {label: ''}])
    assert_empty route.reload.stops
  end

  def test_whitespace_only_rows_are_ignored
    route = DeliveryRoute.create!(stops_attributes: [{label: '  ', notes: " \t "}])
    assert_empty route.reload.stops
  end

  def test_meaningful_rows_are_saved_among_blank_rows
    route = DeliveryRoute.create!(stops_attributes: [{}, {label: 'Depot'}, {label: 'Shop'}])
    assert_equal ['Depot', 'Shop'], route.stops.order(:id).pluck(:label)
  end

  def test_existing_stop_can_be_updated
    route = DeliveryRoute.create!(stops_attributes: [{label: 'Depot'}])
    stop = route.stops.first
    route.update!(stops_attributes: [{id: stop.id, label: 'Warehouse'}])
    assert_equal 'Warehouse', stop.reload.label
  end

  def test_existing_stop_can_be_destroyed
    route = DeliveryRoute.create!(stops_attributes: [{label: 'Depot'}])
    stop = route.stops.first
    route.update!(stops_attributes: [{id: stop.id, _destroy: '1'}])
    refute Stop.exists?(stop.id)
  end

  def test_new_destroyed_row_is_not_created
    route = DeliveryRoute.create!(stops_attributes: [{label: 'Discard', _destroy: '1'}])
    assert_empty route.reload.stops
  end

  def test_notes_only_row_is_invalid_and_does_not_partially_save
    route = DeliveryRoute.new(stops_attributes: [{label: 'Valid'}, {notes: 'Needs a label'}])
    refute route.save
    assert route.errors.any?
    assert_equal 0, DeliveryRoute.count
    assert_equal 0, Stop.count
  end
end
