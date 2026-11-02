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

  def test_only_the_right_password_works
    ana = Staff.create!(email: 'ana@example.com', password: 'ana secret')
    bo = Staff.create!(email: 'bo@example.com', password: 'bo secret')
    ['bo secret', '', 'ana secret ', 'ANA SECRET', 'x'].each { refute ana.authenticate(_1), "accepted #{_1.inspect}" }
    assert_equal bo, bo.authenticate('bo secret')
    refute bo.authenticate('ana secret')
  end

  def test_new_password_replaces_the_old
    staff = Staff.create!(email: 'd@example.com', password: 'first one')
    staff.update!(password: 'second one')
    row = Staff.find(staff.id)
    refute row.authenticate('first one')
    assert_equal row, row.authenticate('second one')
  end

  def test_requires_password_on_create
    refute Staff.new(email: 'b@example.com').valid?
  end

  def test_confirmation_must_match
    refute Staff.new(email: 'c@example.com', password: 'one', password_confirmation: 'two').valid?
  end
end
