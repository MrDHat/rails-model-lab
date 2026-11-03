require 'minitest/autorun'
require_relative 'setup'

class ResetTokenTest < Minitest::Test
  include ActiveSupport::Testing::TimeHelpers

  def setup
    @account = Account.create!(email: 'a@example.com', password_digest: 'digest-one-abcdefghij')
  end

  def test_token_finds_account
    assert_equal @account, Account.find_by_password_reset_token(@account.password_reset_token)
  end

  def test_token_expires
    token = @account.password_reset_token
    travel 16.minutes do
      assert_nil Account.find_by_password_reset_token(token)
    end
  end

  def test_password_change_invalidates
    token = @account.password_reset_token
    @account.update!(password_digest: 'digest-two-0123456789')
    assert_nil Account.find_by_password_reset_token(token)
  end

  def test_any_digest_change_invalidates
    token = @account.password_reset_token
    @account.update!(password_digest: 'digest-two-abcdefghij')
    assert_nil Account.find_by_password_reset_token(token)
  end

  def test_token_is_for_its_own_account
    other = Account.create!(email: 'b@example.com', password_digest: 'digest-other-abcdefghij')
    assert_equal other, Account.find_by_password_reset_token(other.password_reset_token)
    assert_equal @account, Account.find_by_password_reset_token(@account.password_reset_token)
  end

  def test_tampered_token
    assert_nil Account.find_by_password_reset_token("#{@account.password_reset_token}x")
  end
end
