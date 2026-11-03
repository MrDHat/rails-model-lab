require 'minitest/autorun'
require_relative 'setup'

class ProjectSlugApiTest < Minitest::Test
  def test_uses_scoped_case_insensitive_uniqueness
    validator = Project.validators_on(:slug).grep(ActiveRecord::Validations::UniquenessValidator).first
    assert validator
    assert_equal [:account_id], Array(validator.options[:scope])
    assert_equal false, validator.options[:case_sensitive]
  end
end
