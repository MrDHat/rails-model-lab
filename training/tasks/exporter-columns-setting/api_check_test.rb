require 'minitest/autorun'
require_relative 'setup'
require_relative '../../lib/answer_calls'

class ExporterColumnsApiTest < Minitest::Test
  def test_uses_class_attribute
    assert_includes AnswerCalls.names(__dir__), :class_attribute
  end
end
