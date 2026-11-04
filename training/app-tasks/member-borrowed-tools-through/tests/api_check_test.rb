require "test_helper"

class MemberBorrowedToolsThroughApiTest < ActiveSupport::TestCase
  test "borrowed_tools is a has_many :through association" do
    reflection = Member.reflect_on_association(:borrowed_tools)
    assert reflection&.through_reflection?, "borrowed_tools is not a :through association"
  end
end
