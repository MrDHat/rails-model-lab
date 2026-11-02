# Shared by both test files: schema, then the implementation under test.
require 'active_record'
require 'active_support/all'
require 'bigdecimal'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :entries do |t|
    t.string :title
  end
  create_table :labels do |t|
    t.string :name
  end
  create_table :labelings do |t|
    t.references :entry
    t.references :label
  end
end

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)
