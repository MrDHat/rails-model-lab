require 'minitest/autorun'
require_relative 'setup'

class ProfileUpdateTest < Minitest::Test
  def test_creates_profile_when_missing
    person = Person.create!(name: 'Ana', profile_attributes: { bio: 'Hi' })
    assert_equal 'Hi', person.reload.profile.bio
  end

  def test_updates_existing_profile_in_place
    person = Person.create!(name: 'Bo', profile_attributes: { bio: 'Old' })
    profile_id = person.profile.id
    person.update!(profile_attributes: { bio: 'New' })
    assert_equal profile_id, person.reload.profile.id
    assert_equal 'New', person.profile.bio
    assert_equal 1, Profile.where(person_id: person.id).count
  end
end
