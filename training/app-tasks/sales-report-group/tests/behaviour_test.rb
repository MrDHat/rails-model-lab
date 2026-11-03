require "test_helper"

class SalesReportGroupTest < ActionDispatch::IntegrationTest
  def order(at, status: Order::PLACED, **items)
    order = Order.create!(customer: customers(:tom), placed_at: at, status: status)
    items.each { |sku, quantity| order.order_items.create!(product: Product.find_by!(sku: sku.to_s.upcase), quantity: quantity, unit_price_cents: 100) }
  end

  def report(from, to)
    loads = 0
    counter = ->(*, payload) { loads += 1 if payload[:sql].match?(/SELECT "order_items"\.\*|SELECT "order_items"\."/) }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { get admin_sales_path(from: from, to: to) }
    assert_response :success
    assert_equal 0, loads, "loaded order items into the app"
    css_select("tbody tr").map { |row| row.css("td").map { _1.text.strip } }
  end

  test "units and revenue per product, highest revenue first" do
    order(Time.utc(2026, 3, 5, 9), cro: 3, ecl: 10)
    assert_equal [["Éclair", "10", "€10.00"], ["Croissant", "5", "€5.80"], ["Baguette", "2", "€2.40"]],
                 report("2026-03-01", "2026-03-31")
  end

  test "cancelled orders don't count" do
    order(Time.utc(2026, 3, 5, 9), status: Order::CANCELLED, ecl: 10)
    assert_equal [["Croissant", "2", "€2.80"], ["Baguette", "2", "€2.40"]], report("2026-03-01", "2026-03-31")
  end

  test "the period is Paris days, both ends included" do
    order(Time.utc(2026, 3, 9, 23, 30), ecl: 1)
    order(Time.utc(2026, 3, 1, 23, 1), cro: 1)
    order(Time.utc(2026, 3, 1, 22, 59), ecl: 7)
    order(Time.utc(2026, 3, 10, 23, 30), bag: 4)
    assert_equal [["Croissant", "3", "€3.80"], ["Baguette", "2", "€2.40"]], report("2026-03-02", "2026-03-02")
    assert_equal [["Éclair", "1", "€1.00"]], report("2026-03-10", "2026-03-10")
    assert_empty report("2026-04-01", "2026-04-30")
  end
end
