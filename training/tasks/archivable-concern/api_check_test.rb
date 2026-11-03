require 'minitest/autorun'
require_relative 'setup'

class ArchivableApiTest < Minitest::Test
  def test_is_a_concern
    assert Archivable.is_a?(ActiveSupport::Concern)
  end
end
