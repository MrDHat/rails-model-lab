require 'minitest/autorun'
require_relative 'setup'

class NewsletterTest < Minitest::Test
  # Runs `competitor` once, just after the first query matching `pattern`,
  # as if another server acted between this code's read and its write.
  def with_competitor(pattern, competitor)
    fired = false
    callback = lambda do |*, payload|
      next if fired || !payload[:sql].match?(pattern)
      fired = true
      competitor.call
    end
    result = ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') { yield }
    [result, fired]
  end

  def test_signup_that_lands_between_check_and_insert
    insert = -> { Subscription.connection.execute("INSERT INTO subscriptions (email) VALUES ('c@example.com')") }
    row, = with_competitor(/\ASELECT .*subscriptions/i, insert) { Newsletter.subscribe('c@example.com') }
    assert_equal 'c@example.com', row.email
    assert_equal 1, Subscription.where(email: 'c@example.com').count
  end
  def test_creates_then_returns_existing
    first = Newsletter.subscribe('a@example.com')
    assert_equal first.id, Newsletter.subscribe('a@example.com').id
    assert_equal 1, Subscription.where(email: 'a@example.com').count
  end

  def test_row_inserted_elsewhere
    Subscription.connection.execute("INSERT INTO subscriptions (email) VALUES ('b@example.com')")
    assert_equal 'b@example.com', Newsletter.subscribe('b@example.com').email
  end
end
