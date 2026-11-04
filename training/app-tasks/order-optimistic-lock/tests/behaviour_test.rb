require "test_helper"

class OrderOptimisticLockTest < ActionDispatch::IntegrationTest
  def order_json(order = orders(:lea_morning))
    get api_order_path(order, api_key: api_key), as: :json
    response.parsed_body
  end

  def save_notes(notes, version, order = orders(:lea_morning))
    patch api_order_path(order, api_key: api_key), params: { notes: notes, version: version }, as: :json
  end

  test "the JSON carries the notes and a version" do
    json = order_json
    assert_nil json["notes"]
    assert_kind_of Integer, json["version"]
  end

  test "a notes change with the current version saves and moves the version on" do
    seen = order_json["version"]
    save_notes("No sesame", seen)
    assert_response :success
    assert_equal "No sesame", response.parsed_body["notes"]
    assert_not_equal seen, response.parsed_body["version"]
    assert_equal "No sesame", orders(:lea_morning).reload.notes
  end

  test "a stale version is a conflict and saves nothing" do
    seen = order_json["version"]
    save_notes("No sesame", seen)
    save_notes("Extra crispy", seen)
    assert_response :conflict
    assert_equal({ "error" => "This order was changed by someone else" }, response.parsed_body)
    assert_equal "No sesame", orders(:lea_morning).reload.notes
  end

  test "a kitchen status change also makes older versions stale" do
    seen = order_json["version"]
    patch api_order_path(orders(:lea_morning), api_key: api_key), params: { status: Order::BAKING }, as: :json
    assert_response :success
    save_notes("Extra crispy", seen)
    assert_response :conflict
    assert_nil orders(:lea_morning).reload.notes
    save_notes("Extra crispy", order_json["version"])
    assert_response :success
  end

  test "status changes without a version always apply" do
    seen = order_json["version"]
    save_notes("No sesame", seen)
    patch api_order_path(orders(:lea_morning), api_key: api_key), params: { status: Order::BAKING }, as: :json
    assert_response :success
    assert_equal Order::BAKING, orders(:lea_morning).reload.status
  end
end
