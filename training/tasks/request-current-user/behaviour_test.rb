require 'minitest/autorun'
require_relative 'setup'

class CurrentUserTest < Minitest::Test
  def teardown
    Current.reset
  end

  def test_note_takes_current_user
    Current.user = 'ana'
    assert_equal 'ana', Note.create!(body: 'hi').reload.author
  end

  def test_reset_clears
    Current.user = 'ana'
    Current.reset
    assert_nil Current.user
  end

  def test_threads_are_isolated
    Current.user = 'ana'
    assert_nil Thread.new { Current.user }.value
    assert_equal 'ana', Current.user
  end
end
