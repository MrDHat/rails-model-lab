require "test_helper"

class CategoryDeleteGuardApiTest < ActiveSupport::TestCase
  test "the association restricts destroy" do
    assert_equal :restrict_with_error, Category.reflect_on_association(:tools).options[:dependent]
  end
end
