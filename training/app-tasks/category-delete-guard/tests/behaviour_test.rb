require "test_helper"

class CategoryDeleteGuardTest < ActionDispatch::IntegrationTest
  test "a category with tools stays, with an alert" do
    category = categories(:power)
    assert_no_difference(["Category.count", "Tool.count"]) { delete category_path(category) }
    assert_redirected_to categories_path
    assert_match(/tools/i, flash[:alert].to_s)
    assert_equal category, tools(:drill).reload.category
  end

  test "destroy returns false and keeps everything" do
    category = categories(:garden)
    assert_equal false, category.destroy
    assert Category.exists?(category.id)
    assert_equal category, tools(:trimmer).reload.category
  end

  test "an empty category still deletes" do
    empty = Category.create!(name: "Woodwork")
    assert_difference("Category.count", -1) { delete category_path(empty) }
    assert_redirected_to categories_path
    assert_equal "Category deleted", flash[:notice]
  end

  test "a category whose tools are all moved away can be deleted" do
    category = categories(:garden)
    tools(:trimmer).update!(category: categories(:power))
    assert category.destroy
  end
end
