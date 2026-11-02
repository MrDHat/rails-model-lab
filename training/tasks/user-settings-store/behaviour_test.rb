require 'minitest/autorun'
require_relative 'setup'

class UserSettingsTest < Minitest::Test
  def test_values_round_trip_through_settings
    id = User.create!(theme: 'dark', digest: 'weekly').id
    row = User.find(id)
    assert_equal 'dark', row.theme
    assert_equal 'weekly', row.digest
    assert_equal({ 'theme' => 'dark', 'digest' => 'weekly' }, row.settings)
  end

  def test_setting_one_keeps_the_other
    row = User.create!(theme: 'dark', digest: 'weekly')
    row.update!(digest: 'daily')
    row.reload
    assert_equal 'dark', row.theme
    assert_equal 'daily', row.digest
    row.theme = 'light'
    assert_equal 'light', row.theme
    assert_equal 'daily', row.digest
  end

  def test_other_keys_survive
    row = User.create!(settings: { 'beta' => true })
    row.update!(theme: 'light')
    assert_equal({ 'beta' => true, 'theme' => 'light' }, row.reload.settings)
  end

  def test_unset_value_reads_nil
    assert_nil User.new.theme
    assert_nil User.new.digest
  end
end
