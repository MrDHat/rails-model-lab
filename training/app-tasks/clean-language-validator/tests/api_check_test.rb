require "test_helper"

class CleanLanguageValidatorApiTest < ActiveSupport::TestCase
  def custom_each_validators(model, attribute)
    model.validators_on(attribute).select do |validator|
      validator.is_a?(ActiveModel::EachValidator) && !validator.class.name.start_with?("ActiveModel::", "ActiveRecord::")
    end
  end

  test "one custom EachValidator checks every field" do
    validators = [[Comment, :body], [Letter, :subject], [Letter, :body]].map { custom_each_validators(*_1) }
    assert validators.all?(&:any?), "a field has no custom EachValidator"
    assert_equal 1, validators.flatten.map(&:class).uniq.size
  end
end
