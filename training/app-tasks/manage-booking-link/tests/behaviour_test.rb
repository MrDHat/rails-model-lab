require "test_helper"

class ManageBookingLinkTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.utc(2026, 6, 10, 12)
    @appointment = appointments(:julia_monday)
  end

  teardown { travel_back }

  def link_path(appointment = @appointment)
    url = AppointmentMailer.confirmation(appointment.reload).body.to_s[%r{http://example\.com(/bookings/\S+)}, 1]
    assert url, "no booking link in the confirmation email"
    url
  end

  test "the emailed link shows the booking and doesn't use the id" do
    path = link_path
    assert_not_equal "/bookings/#{@appointment.id}", path
    get path
    assert_response :success
    assert_includes response.body, "Physiotherapy session with Ana Souza"
  end

  test "the link cancels the appointment" do
    path = link_path
    delete path
    assert_response :success
    assert_includes response.body, "Your appointment has been cancelled."
    assert @appointment.reload.cancelled?
  end

  test "an id or a made-up token is a 404" do
    get "/bookings/#{@appointment.id}"
    assert_response :not_found
    delete "/bookings/#{@appointment.id}"
    assert_response :not_found
    assert @appointment.reload.booked?
    get "#{link_path}x"
    assert_response :not_found
  end

  test "a cancelled appointment's link stops working" do
    path = link_path
    @appointment.cancel!(reason: "Away")
    get path
    assert_response :not_found
  end

  test "moving the appointment replaces the link" do
    old_path = link_path
    @appointment.reschedule!(Time.utc(2026, 6, 17, 12))
    get old_path
    assert_response :not_found
    get link_path
    assert_response :success
  end

  test "links expire after 30 days" do
    path = link_path
    travel 29.days
    get path
    assert_response :success
    travel 2.days
    get path
    assert_response :not_found
  end

  test "each appointment's link is its own" do
    get link_path(appointments(:marcos_monday))
    assert_includes response.body, "Sports massage with Ana Souza"
  end
end
