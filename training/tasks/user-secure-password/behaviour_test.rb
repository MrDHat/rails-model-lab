require 'minitest/autorun'
require_relative 'setup'

class StaffPasswordTest < Minitest::Test
  def test_authenticates_and_hashes
    staff = Staff.create!(email: 'a@example.com', password: 'correct horse')
    row = Staff.find(staff.id)
    assert_equal row, row.authenticate('correct horse')
    refute row.authenticate('wrong')
    assert BCrypt::Password.valid_hash?(row.password_digest)
  end

  def test_requires_password_on_create
    refute Staff.new(email: 'b@example.com').valid?
  end

  def test_confirmation_must_match
    refute Staff.new(email: 'c@example.com', password: 'one', password_confirmation: 'two').valid?
  end
end
