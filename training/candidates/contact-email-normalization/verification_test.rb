require 'active_record'
require 'active_support/all'
require 'minitest/autorun'
require 'bigdecimal'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :contacts do |t|
    t.string :email
  end
end

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)

class ContactEmailTest < Minitest::Test
  def setup
    Contact.delete_all
  end

  def test_assignment_is_normalized_without_saving
    assert_equal 'alice@example.test', Contact.new(email: "  ALICE@EXAMPLE.TEST \n").email
  end

  def test_persistence_stores_the_canonical_value
    contact = Contact.create!(email: ' ALICE@EXAMPLE.TEST ')
    assert_equal 'alice@example.test', contact.reload.email
  end

  def test_hash_lookup_normalizes_the_argument
    contact = Contact.create!(email: 'alice@example.test')
    assert_equal contact.id, Contact.find_by(email: '  ALICE@EXAMPLE.TEST ')&.id
  end

  def test_reassignment_is_normalized_immediately
    contact = Contact.create!(email: 'alice@example.test')
    contact.email = ' BOB@EXAMPLE.TEST '
    assert_equal 'bob@example.test', contact.email
    contact.save!
    assert_equal 'bob@example.test', contact.reload.email
  end

  def test_nil_is_invalid_without_raising
    contact = Contact.new(email: nil)
    assert_nil contact.email
    refute contact.valid?
  end

  def test_whitespace_is_invalid
    contact = Contact.new(email: " \t ")
    refute contact.valid?
    assert contact.errors[:email].any?
  end

  def test_normalization_is_idempotent
    contact = Contact.new(email: ' ALICE@EXAMPLE.TEST ')
    twice = Contact.new(email: contact.email)
    assert_equal contact.email, twice.email
    assert_equal 'alice@example.test', twice.email
  end
end
