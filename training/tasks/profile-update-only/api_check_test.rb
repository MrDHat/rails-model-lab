require 'minitest/autorun'
require_relative 'setup'

class ProfileUpdateApiTest < Minitest::Test
  def test_update_only_is_declared
    assert Person.nested_attributes_options.fetch(:profile)[:update_only]
  end
end
