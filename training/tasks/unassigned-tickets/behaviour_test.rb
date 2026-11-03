require 'minitest/autorun'
require_relative 'setup'

class UnassignedTest < Minitest::Test
  def test_null_and_dangling_agents
    agent = Agent.create!(name: 'Ana')
    gone = Agent.create!(name: 'Gone')
    SupportCase.create!(agent: agent)
    null_case = SupportCase.create!
    dangling = SupportCase.create!(agent: gone)
    gone.delete
    assert_equal [null_case.id, dangling.id].sort, SupportCase.unassigned.pluck(:id).sort
    assert_kind_of ActiveRecord::Relation, SupportCase.unassigned
  end
end
