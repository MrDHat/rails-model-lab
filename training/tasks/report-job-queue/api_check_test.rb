require 'minitest/autorun'
require_relative 'setup'

class ReportQueueApiTest < Minitest::Test
  def test_queue_as_block
    answer = File.expand_path(ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb'), __dir__)
    assert_kind_of Proc, ReportJob.queue_name
    assert_equal answer, ReportJob.queue_name.source_location.first
  end
end
