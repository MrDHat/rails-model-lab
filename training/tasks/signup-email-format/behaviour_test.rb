require 'minitest/autorun'
require_relative 'setup'

class SignupEmailTest < Minitest::Test
  def assert_invalid(email)
    row = Signup.new(email: email)
    refute row.valid?, "accepted #{email.inspect}"
    assert row.errors[:email].any?
  end

  def test_accepts_ordinary_address
    assert Signup.new(email: 'ana@example.com').valid?
  end

  def test_rejects_missing_and_malformed
    [nil, '', 'ana.example.com', 'ana@@example.com', 'ana @example.com', '@example.com'].each { assert_invalid(_1) }
  end

  def test_rejects_overlong_address
    assert_invalid("#{'a' * 243}@example.com")
    assert Signup.new(email: "#{'a' * 242}@example.com").valid?
  end
end
