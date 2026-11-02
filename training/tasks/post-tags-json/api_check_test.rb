require 'minitest/autorun'
require_relative 'setup'

class PostTagsApiTest < Minitest::Test
  def test_attribute_is_serialized
    assert_kind_of ActiveRecord::Type::Serialized, Post.type_for_attribute(:tags)
  end
end
