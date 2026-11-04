require "test_helper"

class MagicLinkSignInTest < ActionDispatch::IntegrationTest
  setup { ActionMailer::Base.deliveries.clear }

  def request_link(email = "bo@example.com")
    post "/session/link", params: { email: email }
    assert_redirected_to new_session_path
    assert_equal "Check your email", flash[:notice]
  end

  def last_link
    mail = ActionMailer::Base.deliveries.last
    assert_equal ["bo@example.com"], mail.to
    url = mail.text_part&.body&.to_s || mail.body.to_s
    url[%r{http://example\.com/session/link\?token=\S+}] || flunk("no link in #{url}")
  end

  def open_link(url)
    delete session_path
    get url.delete_prefix("http://example.com")
  end

  def assert_signed_in
    assert_redirected_to tools_path
    assert_equal members(:bo).id, session[:member_id]
  end

  def assert_refused
    assert_redirected_to new_session_path
    assert_equal "That link has expired", flash[:alert]
    assert_nil session[:member_id]
  end

  test "a link signs the member in" do
    request_link
    open_link(last_link)
    assert_signed_in
  end

  test "an unknown email gets the same answer and no email" do
    request_link("nobody@example.com")
    assert_empty ActionMailer::Base.deliveries
  end

  test "a link works only once" do
    request_link
    link = last_link
    open_link(link)
    assert_signed_in
    open_link(link)
    assert_refused
  end

  test "using a link cancels the earlier ones" do
    request_link
    older = last_link
    travel 1.minute
    request_link
    open_link(last_link)
    assert_signed_in
    open_link(older)
    assert_refused
  end

  test "an unused earlier link still works until it expires" do
    request_link
    older = last_link
    request_link
    open_link(older)
    assert_signed_in
  end

  test "a link expires after 15 minutes" do
    request_link
    link = last_link
    travel 16.minutes
    open_link(link)
    assert_refused
  end

  test "a forged token is refused" do
    open_link("http://example.com/session/link?token=#{members(:bo).id}")
    assert_refused
  end
end
