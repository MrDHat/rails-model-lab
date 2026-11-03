# Shared by both test files: schema, then the implementation under test.
require 'active_record'
require 'active_support/all'
require 'bigdecimal'
require 'active_support/testing/time_helpers'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false

module RateSource
  class << self
    attr_accessor :calls
  end
  self.calls = 0

  def self.rates
    self.calls += 1
    { 'usd' => 1.0 }
  end
end

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)
