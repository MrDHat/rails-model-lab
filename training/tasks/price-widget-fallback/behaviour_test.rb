require 'minitest/autorun'
require_relative 'setup'

class PriceWidgetTest < Minitest::Test
  class Collector
    attr_reader :reports

    def initialize = @reports = []

    def report(error, handled:, **)
      @reports << [error.class, handled]
    end
  end

  def setup
    @collector = Collector.new
    ActiveSupport.error_reporter.subscribe(@collector)
  end

  def teardown
    ActiveSupport.error_reporter.unsubscribe(@collector)
    PriceFeed.down = false
  end

  def test_shows_price
    assert_equal 'A1: $10', PriceWidget.render('A1')
    assert_empty @collector.reports
  end

  def test_fallback_and_report
    PriceFeed.down = true
    assert_equal 'Price unavailable', PriceWidget.render('A1')
    assert_equal [[IOError, true]], @collector.reports
  end
end
