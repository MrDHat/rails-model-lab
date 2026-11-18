require "test_helper"

class PractitionerBufferTimeTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.utc(2026, 6, 14, 12)
    @ana = practitioners(:ana)
  end

  teardown { travel_back }

  def set_buffer(value)
    sign_in_staff staff_users(:helena)
    patch staff_practitioner_path(@ana), params: { practitioner: { buffer_minutes: value } }
  end

  def slots(treatment = "SPRT")
    get api_slots_path(practitioner_id: @ana.id, treatment: treatment, date: "2026-06-15"), headers: api_headers, as: :json
    response.parsed_body["slots"].map { Time.zone.parse(_1).strftime("%H:%M") }
  end

  test "managers set it on the edit page" do
    sign_in_staff staff_users(:helena)
    get edit_staff_practitioner_path(@ana)
    assert_select "input[name=?]", "practitioner[buffer_minutes]"
    set_buffer("15")
    assert_redirected_to staff_practitioner_path(@ana)
    assert_equal 15, @ana.reload.settings["buffer_minutes"].to_i
    assert_equal 15, @ana.buffer_minutes.to_i
  end

  test "values outside 0 to 60 are refused" do
    ["61", "-5", "7.5", "soon"].each do |value|
      set_buffer(value)
      assert_response :unprocessable_entity, value
      assert_select ".errors li", "Buffer minutes must be in 0..60"
    end
    assert_equal 0, @ana.reload.buffer_minutes.to_i
  end

  test "0 unless set, and the slots stay as they were" do
    assert_equal 0, @ana.buffer_minutes.to_i
    assert_equal %w[08:00 08:15 08:30 09:45 10:00 10:15 10:30 11:30], slots.first(8)
  end

  test "the slot search keeps the buffer free around appointments" do
    set_buffer("15")
    # Booked 09:00–09:45 and 11:00–11:30.
    assert_equal %w[08:00 08:15 10:00 10:15 14:00 14:15], slots.first(6)
  end

  test "cancelled appointments still don't count" do
    set_buffer("30")
    appointments(:julia_monday).cancel!(reason: "Away")
    assert_equal %w[08:00 08:15 08:30 08:45 09:00 09:15 09:30 09:45 10:00], slots.first(9)
  end

  test "the API shows it" do
    set_buffer("20")
    get api_practitioner_path(@ana), headers: api_headers, as: :json
    assert_equal 20, response.parsed_body["buffer_minutes"]
    get api_practitioner_path(practitioners(:bruno)), headers: api_headers, as: :json
    assert_equal 0, response.parsed_body["buffer_minutes"]
  end

  test "other settings are kept" do
    @ana.update_columns(settings: { "room_preference" => "Room 2" })
    set_buffer("10")
    assert_equal({ "room_preference" => "Room 2", "buffer_minutes" => 10 }, @ana.reload.settings.transform_values { _1.to_s.match?(/\A\d+\z/) ? _1.to_i : _1 })
  end
end
