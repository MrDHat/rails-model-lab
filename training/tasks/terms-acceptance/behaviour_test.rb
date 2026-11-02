require 'minitest/autorun'
require_relative 'setup'

class TermsAcceptanceTest < Minitest::Test
  def test_ticked_box_creates_member
    assert Member.new(name: 'Ana', terms_of_service: '1').save
  end

  def test_unticked_or_missing_box_is_rejected
    [{ terms_of_service: '0' }, {}, { terms_of_service: nil }, { terms_of_service: '' },
     { terms_of_service: 'yes' }, { terms_of_service: 'no' }].each do |extra|
      row = Member.new(name: 'Ana', **extra)
      refute row.save
      assert row.errors[:terms_of_service].any?
    end
  end

  def test_existing_member_updates_without_checkbox
    id = Member.create!(name: 'Ana', terms_of_service: '1').id
    assert Member.find(id).update(name: 'Ana B')
  end
end
