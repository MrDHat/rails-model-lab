require 'minitest/autorun'
require_relative 'setup'

class ExporterColumnsTest < Minitest::Test
  def test_subclasses_override_independently
    users = Class.new(Exporter) { self.columns = columns + %w[email] }
    orders = Class.new(Exporter) { self.columns = columns + %w[total] }
    plain = Class.new(Exporter)
    assert_equal %w[id], Exporter.columns
    assert_equal %w[id email], users.columns
    assert_equal %w[id total], orders.columns
    assert_equal %w[id], plain.columns
    assert_equal %w[id email], users.new.columns
  end
end
