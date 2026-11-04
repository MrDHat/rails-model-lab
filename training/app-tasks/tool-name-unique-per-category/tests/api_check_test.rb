require "test_helper"

class ToolNameUniquePerCategoryApiTest < ActiveSupport::TestCase
  test "uses a scoped, case-insensitive uniqueness validation" do
    validator = Tool.validators_on(:name).find { _1.is_a?(ActiveRecord::Validations::UniquenessValidator) }
    assert validator, "no uniqueness validation on name"
    assert_includes [[:category_id], [:category]], Array(validator.options[:scope]).map(&:to_sym)
    assert_equal false, validator.options[:case_sensitive]
  end
end
