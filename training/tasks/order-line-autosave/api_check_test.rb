require 'minitest/autorun'
require_relative 'setup'

class OrderAutosaveApiTest < Minitest::Test
  def test_autosave_is_declared
    assert Order.reflect_on_association(:line_items).options[:autosave]
  end
end
