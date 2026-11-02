require 'minitest/autorun'
require_relative 'setup'

class PostTagsApiTest < Minitest::Test
  # serialize with a JSON coder, or the built-in JSON attribute type.
  def test_attribute_has_a_json_type
    type = Post.type_for_attribute(:tags)
    assert type.is_a?(ActiveRecord::Type::Serialized) || type.is_a?(ActiveRecord::Type::Json), type.class.name
  end
end
