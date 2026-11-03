require 'minitest/autorun'
require_relative 'setup'

class SyncJobApiTest < Minitest::Test
  def test_retry_on_is_declared
    assert SyncJob.rescue_handlers.any? { _1.first == 'Timeout::Error' }
  end
end
