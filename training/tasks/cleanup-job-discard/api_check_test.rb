require 'minitest/autorun'
require_relative 'setup'

class CleanupJobApiTest < Minitest::Test
  def test_discard_on_is_declared
    assert CleanupJob.rescue_handlers.any? { _1.first == 'ActiveRecord::RecordNotFound' }
  end
end
