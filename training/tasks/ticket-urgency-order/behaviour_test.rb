require 'minitest/autorun'
require_relative 'setup'

class IssueOrderTest < Minitest::Test
  def setup
    Issue.delete_all
    %i[low urgent normal high urgent].each { Issue.create!(priority: _1) }
  end

  def test_orders_by_business_priority_then_id
    assert_equal %w[urgent urgent high normal low], Issue.by_urgency.map(&:priority)
    urgent = Issue.where(priority: :urgent).order(:id).pluck(:id)
    assert_equal urgent, Issue.by_urgency.first(2).map(&:id)
  end

  def test_stays_chainable
    assert_equal ['urgent'], Issue.by_urgency.limit(1).map(&:priority)
  end
end
