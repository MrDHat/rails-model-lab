require File.join(ENV.fetch("WORKDIR", "/app"), "test/test_helper")

class SubmissionTest < ActionDispatch::IntegrationTest
  VALID = { merchant: "Station Cafe", amount_cents: 1250, incurred_on: "2026-01-12", status: "submitted" }.freeze
  INVALID = {
    merchant: [nil, "", " \t\n"],
    amount_cents: [nil, 0, -1],
    incurred_on: [nil]
  }.freeze

  def create_claim(attributes)
    post "/expense_claims", params: { expense_claim: attributes }, as: :json
  end

  def change_claim(id, attributes)
    patch "/expense_claims/#{id}", params: { expense_claim: attributes }, as: :json
  end

  def saved_claim(attributes = VALID)
    create_claim(attributes)
    assert_response :created
    ExpenseClaim.find(response.parsed_body.fetch("id"))
  end

  def assert_fields(claim, expected)
    expected.each do |field, value|
      actual = claim.public_send(field)
      actual = actual.iso8601 if actual.is_a?(Date)
      value.nil? ? assert_nil(actual) : assert_equal(value, actual)
    end
  end

  def assert_rejected
    assert_response :unprocessable_entity
    errors = response.parsed_body.fetch("errors")
    assert_kind_of Hash, errors
    assert errors.values.flatten.any? { |message| message.is_a?(String) && !message.strip.empty? }
  end

  test "empty and partial drafts remain editable" do
    claim = saved_claim(status: "draft")
    assert_fields claim, status: "draft", merchant: nil, amount_cents: nil, incurred_on: nil
    claim = saved_claim(status: "draft", merchant: "Cafe")
    change_claim claim.id, amount_cents: 250
    assert_response :ok
    assert_fields claim.reload, status: "draft", merchant: "Cafe", amount_cents: 250, incurred_on: nil
  end

  [1, 1250].each do |amount|
    test "complete submission accepts #{amount} cents" do
      values = VALID.merge(amount_cents: amount)
      claim = saved_claim(values)
      assert_fields claim, values
      get "/expense_claims/#{claim.id}", as: :json
      assert_response :ok
      assert_equal claim.id, response.parsed_body.fetch("id")
      values.each { |key, value| assert_equal value, response.parsed_body.fetch(key.to_s) }
    end
  end

  INVALID.each do |field, values|
    values.each_with_index do |value, index|
      test "creation rejects #{field} variant #{index}" do
        assert_no_difference "ExpenseClaim.count" do
          create_claim VALID.merge(field => value)
        end
        assert_rejected
      end

      test "update rejects #{field} variant #{index} without changing saved state" do
        claim = saved_claim
        before = claim.attributes
        change_claim claim.id, field => value
        assert_rejected
        assert_equal before, claim.reload.attributes
      end
    end

    test "creation rejects omitted #{field}" do
      assert_no_difference "ExpenseClaim.count" do
        create_claim VALID.except(field)
      end
      assert_rejected
    end
  end

  test "incomplete draft cannot be submitted" do
    claim = saved_claim(status: "draft")
    before = claim.attributes
    change_claim claim.id, status: "submitted"
    assert_rejected
    assert_equal before, claim.reload.attributes
  end

  test "draft can be completed and submitted in one request" do
    claim = saved_claim(status: "draft")
    change_claim claim.id, VALID
    assert_response :ok
    assert_fields claim.reload, VALID
  end

  test "completed draft can be submitted without resending its details" do
    claim = saved_claim(VALID.merge(status: "draft"))
    change_claim claim.id, status: "submitted"
    assert_response :ok
    assert_fields claim.reload, VALID
  end

  test "submitted claim accepts valid edits" do
    claim = saved_claim
    changes = { merchant: "Bookshop", amount_cents: 3000 }
    change_claim claim.id, changes
    assert_response :ok
    assert_fields claim.reload, VALID.merge(changes)
  end

  test "failed multi-field update is atomic" do
    claim = saved_claim
    before = claim.attributes
    change_claim claim.id, merchant: "Changed merchant", amount_cents: 0
    assert_rejected
    assert_equal before, claim.reload.attributes
  end

  test "unknown status remains invalid on create and update" do
    assert_no_difference "ExpenseClaim.count" do
      create_claim VALID.merge(status: "unknown")
    end
    assert_rejected
    claim = saved_claim
    before = claim.attributes
    change_claim claim.id, status: "unknown"
    assert_rejected
    assert_equal before, claim.reload.attributes
  end

  test "missing records return 404" do
    get "/expense_claims/99999", as: :json
    assert_response :not_found
    change_claim 99999, merchant: "Cafe"
    assert_response :not_found
  end
end
