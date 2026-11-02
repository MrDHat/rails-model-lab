require 'minitest/autorun'
require_relative 'setup'

class LegacyEmailTest < Minitest::Test
  def test_new_name_reads_and_writes
    row = Customer.create!(email: 'ana@example.com')
    assert_equal 'ana@example.com', row.reload.email
    row.email = 'bo@example.com'
    row.save!
    assert_equal 'bo@example.com', row.reload.emailaddr
  end

  def test_old_name_still_reads
    assert_equal 'cy@example.com', Customer.create!(emailaddr: 'cy@example.com').email
  end
end
