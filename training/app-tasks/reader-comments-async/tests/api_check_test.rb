require "test_helper"

class ReaderCommentsAsyncApiTest < ActiveSupport::TestCase
  test "comments go with dependent: :destroy_async" do
    assert_equal :destroy_async, Reader.reflect_on_association(:comments).options[:dependent]
  end
end
