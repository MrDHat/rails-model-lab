require 'minitest/autorun'
require_relative 'setup'

class ReportQueueApiTest < Minitest::Test
  def test_queue_as_block
    answer = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
    assert_kind_of Proc, ReportJob.queue_name
    assert_equal answer, File.basename(ReportJob.queue_name.source_location.first)
  end
end
