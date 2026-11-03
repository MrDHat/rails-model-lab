require 'minitest/autorun'
require_relative 'setup'

class LeadImportTest < Minitest::Test
  def test_adds_new_and_keeps_existing
    Lead.delete_all
    Lead.create!(email: 'old@example.com', source: 'website')
    writes = 0
    counter = ->(*, payload) { writes += 1 if payload[:sql].match?(/\A\s*(INSERT|UPDATE)/i) }
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
      LeadImport.call([{ email: 'old@example.com', source: 'expo' }, { email: 'new@example.com', source: 'expo' }])
    end
    assert_equal({ 'old@example.com' => 'website', 'new@example.com' => 'expo' }, Lead.pluck(:email, :source).to_h)
    assert_equal 1, writes
  end
end
