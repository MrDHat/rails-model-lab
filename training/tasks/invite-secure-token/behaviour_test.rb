require 'minitest/autorun'
require_relative 'setup'

class InviteCodeTest < Minitest::Test
  def test_code_is_set_on_create
    code = Invite.create!(email: 'a@example.com').reload.code
    assert_match(/\A[a-zA-Z0-9]{24,}\z/, code)
  end

  def test_regenerate_saves_a_new_code
    invite = Invite.create!(email: 'b@example.com')
    old = invite.code
    invite.regenerate_code
    refute_equal old, invite.reload.code
    assert_match(/\A[a-zA-Z0-9]{24,}\z/, invite.code)
  end
end
