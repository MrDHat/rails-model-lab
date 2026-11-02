require 'minitest/autorun'
require_relative 'setup'

class CheckoutEventTest < Minitest::Test
  def capture(&block)
    events = []
    callback = ->(*args) { events << ActiveSupport::Notifications::Event.new(*args) }
    ActiveSupport::Notifications.subscribed(callback, 'checkout.shop', &block)
    events
  end

  def teardown
    PaymentGateway.fail = false
    PaymentGateway.delay = nil
  end

  def test_duration_covers_the_charge
    PaymentGateway.delay = 0.05
    events = capture { Checkout.call(order_id: 9, cents: 500) }
    assert_operator events.first.duration, :>=, 45
    PaymentGateway.fail = true
    events = capture { assert_raises(RuntimeError) { Checkout.call(order_id: 9, cents: 500) } }
    assert_operator events.first.duration, :>=, 45
  end

  def test_event_on_success
    result = nil
    events = capture { result = Checkout.call(order_id: 9, cents: 500) }
    assert_equal :charged, result
    assert_equal 1, events.size
    assert_equal 9, events.first.payload[:order_id]
    assert_equal 500, events.first.payload[:cents]
  end

  def test_event_on_failure
    PaymentGateway.fail = true
    events = capture { assert_raises(RuntimeError) { Checkout.call(order_id: 9, cents: 500) } }
    assert_equal 1, events.size
    assert_equal ['RuntimeError', 'card declined'], events.first.payload[:exception]
    assert_kind_of RuntimeError, events.first.payload[:exception_object]
    assert_equal 9, events.first.payload[:order_id]
  end
end
