require 'minitest/autorun'
require_relative 'setup'

class PatientTaxIdTest < Minitest::Test
  def raw(patient)
    Patient.connection.select_value("SELECT tax_id FROM patients WHERE id = #{patient.id}")
  end

  def test_reads_plain_value
    assert_equal '123-45-6789', Patient.find(Patient.create!(tax_id: '123-45-6789').id).tax_id
  end

  def test_raw_column_is_not_plain_and_not_repeated
    one = Patient.create!(tax_id: '123-45-6789')
    two = Patient.create!(tax_id: '123-45-6789')
    refute_includes raw(one), '123-45-6789'
    refute_equal raw(one), raw(two)
  end
end
