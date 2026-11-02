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

  # Encoding is not encryption: the ID must not be recoverable without a key.
  def test_raw_column_is_not_an_encoding_of_the_id
    id = '987-65-4321'
    stored = raw(Patient.create!(tax_id: id))
    encodings = [Base64.strict_encode64(id), Base64.urlsafe_encode64(id, padding: false),
                 Base64.strict_encode64(id).delete('='), id.unpack1('H*'), id.reverse, id.tr('0-9', '5-90-4')]
    encodings.each { refute_includes stored, _1 }
  end
end
