require "test_helper"

class TicketsTest < ActionDispatch::IntegrationTest
  setup do
    @team = Team.create!(name: "Support")
    @ticket = @team.tickets.create!(title: "Printer issue")
    @headers = { "X-Team-ID" => @team.id.to_s }
  end

  test "list read and edit own ticket" do
    get "/tickets", headers: @headers, as: :json
    assert_response :ok
    assert_equal [@ticket.id], response.parsed_body.map { |row| row.fetch("id") }
    get "/tickets/#{@ticket.id}", headers: @headers, as: :json
    assert_response :ok
    assert_equal @ticket.title, response.parsed_body.fetch("title")
    patch "/tickets/#{@ticket.id}", params: { ticket: { status: "closed" } }, headers: @headers, as: :json
    assert_response :ok
    assert_equal "closed", @ticket.reload.status
  end

  test "invalid edits preserve the ticket" do
    patch "/tickets/#{@ticket.id}", params: { ticket: { title: "", status: "unknown" } }, headers: @headers, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body.fetch("errors").present?
    assert_equal "Printer issue", @ticket.reload.title
    assert_equal "open", @ticket.status
  end

  test "missing identity and tickets retain existing responses" do
    get "/tickets", as: :json
    assert_response :unauthorized
    get "/tickets/99999", headers: @headers, as: :json
    assert_response :not_found
  end
end
