# Shared by both test files: schema, then the implementation under test.
require 'active_record'
require 'active_support/all'
require 'bigdecimal'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :people do |t|
    t.string :name
  end
  create_table :profiles do |t|
    t.references :person
    t.string :bio
  end
end

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)
