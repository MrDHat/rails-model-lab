require "test_helper"

class OrdersExportBatchesTest < ActionDispatch::IntegrationTest
  def export
    order_loads = []
    counter = lambda do |*, payload|
      next unless payload[:sql].match?(/SELECT "orders"\.\* FROM "orders"/)

      binds = Array(payload[:type_casted_binds].respond_to?(:call) ? payload[:type_casted_binds].call : payload[:type_casted_binds])
      order_loads << payload[:sql].sub(/LIMIT \?/) { "LIMIT #{binds.last}" }
    end
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { get export_admin_orders_path }
    assert_response :success
    assert_equal "application/x-ndjson", response.media_type
    [response.body.lines.map { JSON.parse(_1) }, order_loads]
  end

  test "one line per order, in id order" do
    lines, = export
    assert_equal Order.order(:id).map { _1.as_api.as_json }, lines
  end

  test "loads at most 500 orders at a time" do
    now = Time.current
    Order.insert_all(Array.new(1_150) { { customer_id: customers(:tom).id, placed_at: now, total_cents: _1, created_at: now, updated_at: now } })
    lines, loads = export
    assert_equal 1_152, lines.size
    assert_equal lines.map { _1["id"] }.sort, lines.map { _1["id"] }
    assert_operator loads.size, :>=, 3
    loads.each { |sql| assert_operator sql[/LIMIT (\d+)/, 1].to_i.nonzero? || Float::INFINITY, :<=, 500, sql }
  end
end
