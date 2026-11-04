require "test_helper"

class MemberBorrowedToolsThroughTest < ActionDispatch::IntegrationTest
  setup do
    Loan.delete_all
    @rake = Tool.create!(name: "Rake", serial: "RK-1", category: categories(:garden))
    [tools(:trimmer), tools(:trimmer), @rake, tools(:drill), tools(:trimmer)].each do |tool|
      tool.loans.create!(member: members(:bo), due_on: Date.current + 1).return!
    end
  end

  # The links between the "Tools borrowed" heading and the next heading.
  def borrowed_links
    heading = css_select("h1, h2, h3, h4").find { _1.text.strip == "Tools borrowed" }
    assert heading, "no Tools borrowed heading"
    links = []
    node = heading.next_element
    while node && !node.name.match?(/\Ah[1-4]\z/)
      links.concat(node.name == "a" ? [node] : node.css("a").to_a)
      node = node.next_element
    end
    links
  end

  test "each borrowed tool appears once" do
    assert_equal ["Cordless drill", "Hedge trimmer", "Rake"], members(:bo).borrowed_tools.map(&:name).sort
    assert_empty members(:ana).borrowed_tools
  end

  test "it chains" do
    assert_equal ["Hedge trimmer", "Rake"], members(:bo).borrowed_tools.where(category: categories(:garden)).order(:name).map(&:name)
    @rake.update!(retired_at: Time.current)
    assert_equal 2, members(:bo).borrowed_tools.in_service.count
  end

  test "the member page lists them" do
    get member_path(members(:bo))
    links = borrowed_links
    assert_equal ["Cordless drill", "Hedge trimmer", "Rake"], links.map { _1.text.strip }
    assert_equal tool_path(@rake), links.last["href"]
  end
end
