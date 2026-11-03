# Shared by both test files: schema, then the implementation under test.
require 'active_record'
require 'active_support/all'
require 'bigdecimal'
require 'active_support/testing/time_helpers'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :accounts do |t|
    t.string :email
    t.string :password_digest
  end
end

ActiveRecord::Base.generated_token_verifier =
  ActiveSupport::MessageVerifier.new('k' * 64, digest: 'SHA256', serializer: JSON)

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)
