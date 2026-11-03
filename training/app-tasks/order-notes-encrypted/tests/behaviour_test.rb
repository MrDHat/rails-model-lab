require "test_helper"

class OrderNotesEncryptedTest < ActiveSupport::TestCase
  def stored_notes(order) = Order.connection.select_value("SELECT notes FROM orders WHERE id = #{order.id}")

  test "the column never holds the text" do
    order = Order.place!(customer: customers(:lea), items: [{ sku: "CRO", quantity: 1 }], notes: "Allergic to sesame")
    assert_not_nil stored_notes(order)
    assert_not_includes stored_notes(order), "sesame"
    assert_not_includes Base64.decode64(stored_notes(order).to_s), "sesame"
    orders(:tom_evening).update!(notes: "Coeliac, gluten free please")
    assert_not_includes stored_notes(orders(:tom_evening)), "gluten"
  end

  test "the app reads and writes notes as before" do
    order = Order.place!(customer: customers(:lea), items: [{ sku: "CRO", quantity: 1 }], notes: "No nuts")
    assert_equal "No nuts", Order.find(order.id).notes
    order.update!(notes: "No nuts, no sesame")
    assert_equal "No nuts, no sesame", Order.find(order.id).notes
  end

  test "orders without notes stay NULL" do
    order = Order.place!(customer: customers(:lea), items: [{ sku: "CRO", quantity: 1 }])
    assert_nil stored_notes(order)
    assert_nil order.reload.notes
  end
end
