require 'minitest/autorun'
require_relative 'setup'

class NewsletterTest < Minitest::Test
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
