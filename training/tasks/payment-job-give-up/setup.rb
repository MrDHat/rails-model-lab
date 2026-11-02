# Shared by both test files: schema, then the implementation under test.
require 'active_record'
require 'active_support/all'
require 'bigdecimal'
require 'active_job'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false

ActiveJob::Base.queue_adapter = :test
ActiveJob::Base.logger = Logger.new(nil)

class GatewayDown < StandardError; end

module FailureLog
  def self.entries = (@entries ||= [])
end

module Gateway
  class << self
    attr_accessor :down
  end

  def self.settle(id)
    raise GatewayDown if down || id.negative?
  end
end

implementation = ENV.fetch('CANDIDATE_IMPLEMENTATION', 'reference.rb')
require File.expand_path(implementation, __dir__)
