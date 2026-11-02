require 'minitest/autorun'
require_relative 'setup'

class UserSettingsTest < Minitest::Test
  def test_values_round_trip_through_settings
    id = User.create!(theme: 'dark', digest: 'weekly').id
    row = User.find(id)
    assert_equal 'dark', row.theme
    assert_equal 'weekly', row.settings['digest']
  end

  def test_other_keys_survive
    row = User.create!(settings: { 'beta' => true })
    row.update!(theme: 'light')
    assert_equal({ 'beta' => true, 'theme' => 'light' }, row.reload.settings)
  end

  def test_unset_value_reads_nil
    assert_nil User.new.theme
  end
end
