require File.join(ENV.fetch("WORKDIR", "/app"), "test/test_helper")

class TeamTicketBoundaryTest < ActionDispatch::IntegrationTest
  setup do
    @alpha = Team.create!(name: "Alpha")
    @beta = Team.create!(name: "Beta")
    @empty = Team.create!(name: "Empty")
    @first = @alpha.tickets.create!(title: "Alpha first")
    @foreign = @beta.tickets.create!(title: "Beta private")
    @second = @alpha.tickets.create!(title: "Alpha second", status: "closed")
    @other_foreign = @beta.tickets.create!(title: "Beta second")
  end

  def headers(team = @alpha)
    { "X-Team-ID" => team.id.to_s }
  end

  def snapshot
    Ticket.order(:id).map(&:attributes)
  end

  def edit(ticket, values, team = @alpha)
    patch "/tickets/#{ticket.id}", params: { ticket: values }, headers: headers(team), as: :json
  end

  test "list includes only current team in ascending id order" do
    get "/tickets", headers: headers, as: :json
    assert_response :ok
    assert_kind_of Array, response.parsed_body
    assert_equal [@first.id, @second.id], response.parsed_body.map { |row| row.fetch("id") }
    assert response.parsed_body.all? { |row| row.fetch("team_id") == @alpha.id }
  end

  test "different team sees only its own list" do
    get "/tickets", headers: headers(@beta), as: :json
    assert_response :ok
    assert_equal [@foreign.id, @other_foreign.id], response.parsed_body.map { |row| row.fetch("id") }
  end

  test "team without tickets gets an empty list" do
    get "/tickets", headers: headers(@empty), as: :json
    assert_response :ok
    assert_equal [], response.parsed_body
  end

  test "list query cannot select another team" do
    get "/tickets?team_id=#{@beta.id}", headers: headers, as: :json
    assert_response :ok
    assert_equal [@first.id, @second.id], response.parsed_body.map { |row| row.fetch("id") }
  end

  test "own ticket remains readable with all public fields" do
    get "/tickets/#{@first.id}", headers: headers, as: :json
    assert_response :ok
    assert_equal @first.attributes, response.parsed_body
  end

  test "foreign reads and missing reads both return not found" do
    before = snapshot
    [@foreign.id, @other_foreign.id, Ticket.maximum(:id) + 100].each do |id|
      get "/tickets/#{id}", headers: headers, as: :json
      assert_response :not_found
      assert_not_includes response.body, @foreign.title
      assert_not_includes response.body, @other_foreign.title
    end
    assert_equal before, snapshot
  end

  test "foreign read cannot supply its owner as a query parameter" do
    get "/tickets/#{@foreign.id}?team_id=#{@beta.id}", headers: headers, as: :json
    assert_response :not_found
  end

  test "foreign edits return not found and preserve every record" do
    before = snapshot
    [@foreign, @other_foreign].each do |ticket|
      edit ticket, title: "Leaked edit", status: "closed"
      assert_response :not_found
      assert_equal before, snapshot
    end
  end

  test "foreign edit with invalid attributes still returns not found" do
    before = snapshot
    edit @foreign, title: "", status: "unknown"
    assert_response :not_found
    assert_equal before, snapshot
  end

  test "foreign edit cannot move a ticket into the current team" do
    before = snapshot
    edit @foreign, team_id: @alpha.id, title: "Stolen ticket"
    assert_response :not_found
    assert_equal before, snapshot
  end

  test "scope applies in both directions" do
    before = snapshot
    get "/tickets/#{@first.id}", headers: headers(@beta), as: :json
    assert_response :not_found
    edit @first, { title: "Beta attempted edit" }, @beta
    assert_response :not_found
    assert_equal before, snapshot
  end

  test "own edits preserve ownership and unrelated records" do
    foreign_before = @foreign.attributes
    edit @first, title: "Resolved", status: "closed"
    assert_response :ok
    assert_equal "Resolved", response.parsed_body.fetch("title")
    assert_equal "closed", @first.reload.status
    assert_equal @alpha.id, @first.team_id
    assert_equal foreign_before, @foreign.reload.attributes
    assert_equal "Alpha second", @second.reload.title
  end

  [nil, :other_team, :missing_team].each do |owner|
    test "owner #{owner.inspect} is ignored while valid editable fields apply" do
      value = case owner
              when :other_team then @beta.id
              when :missing_team then Team.maximum(:id) + 100
              else nil
              end
      edit @first, team_id: value, title: "Allowed edit", status: "closed"
      assert_response :ok
      assert_equal "Allowed edit", @first.reload.title
      assert_equal "closed", @first.status
      assert_equal @alpha.id, @first.team_id
      assert_equal @alpha.id, response.parsed_body.fetch("team_id")
    end
  end

  test "invalid own edit returns errors without partial writes or ownership changes" do
    before = snapshot
    edit @first, title: "Changed", status: "unknown", team_id: @beta.id
    assert_response :unprocessable_entity
    errors = response.parsed_body.fetch("errors")
    assert_kind_of Hash, errors
    assert errors.values.flatten.any? { |value| value.is_a?(String) && value.present? }
    assert_equal before, snapshot
  end

  test "missing and unknown identity cannot read or edit" do
    before = snapshot
    [{}, { "X-Team-ID" => (Team.maximum(:id) + 100).to_s }].each do |identity|
      get "/tickets", headers: identity, as: :json
      assert_response :unauthorized
      get "/tickets/#{@first.id}", headers: identity, as: :json
      assert_response :unauthorized
      patch "/tickets/#{@first.id}", params: { ticket: { title: "Unauthorized" } }, headers: identity, as: :json
      assert_response :unauthorized
    end
    assert_equal before, snapshot
  end

  test "missing ticket update retains not found behavior" do
    before = snapshot
    patch "/tickets/#{Ticket.maximum(:id) + 100}", params: { ticket: { title: "Missing" } }, headers: headers, as: :json
    assert_response :not_found
    assert_equal before, snapshot
  end
end
