require 'minitest/autorun'
require_relative 'setup'

class BillClientTest < Minitest::Test
  def test_reads_client_fields
    bill = Bill.create!(client: Client.create!(name: 'Ana', email: 'ana@example.com'))
    assert_equal 'Ana', bill.client_name
    assert_equal 'ana@example.com', bill.client_email
  end

  def test_nil_without_client
    bill = Bill.create!
    assert_nil bill.client_name
    assert_nil bill.client_email
  end
end
