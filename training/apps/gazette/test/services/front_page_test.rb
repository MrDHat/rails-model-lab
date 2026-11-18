require "test_helper"

class FrontPageTest < ActiveSupport::TestCase
  test "the lead is the newest live story" do
    assert_equal articles(:harbour_bridge), FrontPage.new.lead
  end

  test "each section with live stories gets a block, without the lead" do
    blocks = FrontPage.new.blocks
    assert_equal sections(:business, :news, :opinion, :sport).map(&:name).sort, blocks.map { _1.section.name }.sort
    news = blocks.find { _1.section == sections(:news) }
    assert_equal [articles(:council_budget)], news.articles
  end
end
