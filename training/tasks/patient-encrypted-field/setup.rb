# Shared by both test files: schema, then the implementation under test.
require 'active_record'
require 'active_support/all'
require 'bigdecimal'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :patients do |t|
    t.string :tax_id
  end
end

ActiveRecord::Encryption.configure(primary_key: 'p' * 32, deterministic_key: 'd' * 32, key_derivation_salt: 's' * 32)

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)
