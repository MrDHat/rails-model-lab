require 'minitest/autorun'
require_relative 'setup'

class BillingAddressTest < Minitest::Test
  def test_creates_and_links_address
    purchase = Purchase.create!(billing_address_attributes: { line1: '1 Main St', city: 'Cork' })
    assert_equal 'Cork', purchase.reload.billing_address.city
  end

  def test_updates_existing_address
    purchase = Purchase.create!(billing_address_attributes: { line1: '1 Main St', city: 'Cork' })
    address_id = purchase.billing_address_id
    addresses = Address.count
    purchase.update!(billing_address_attributes: { id: address_id, line1: '2 High St', city: 'Cork' })
    assert_equal address_id, purchase.reload.billing_address_id
    assert_equal '2 High St', Address.find(address_id).line1
    assert_equal addresses, Address.count
  end
end
