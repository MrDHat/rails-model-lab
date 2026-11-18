require "test_helper"

class SectionTest < ActiveSupport::TestCase
  test "slugs are lowercase words" do
    assert_not Section.new(name: "Arts", slug: "Arts & Books").valid?
    assert Section.new(name: "Arts", slug: "arts-and-books").valid?
  end

  test "sections with stories can't be deleted" do
    assert_not sections(:sport).destroy
    assert Section.exists?(sections(:sport).id)
  end

  test "latest lists live stories, newest first" do
    assert_equal [articles(:harbour_bridge), articles(:council_budget)], sections(:news).latest.to_a
  end
end
