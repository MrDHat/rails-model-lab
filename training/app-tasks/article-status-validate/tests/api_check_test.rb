require "test_helper"

class ArticleStatusValidateApiTest < ActiveSupport::TestCase
  test "the status enum validates its values" do
    article = Article.new(section: sections(:news), headline: "Test", status: "live")
    assert_not article.valid?
    assert article.errors.of_kind?(:status, :inclusion)
    assert Article.validators_on(:status).any? { _1.is_a?(ActiveModel::Validations::InclusionValidator) }
  end
end
