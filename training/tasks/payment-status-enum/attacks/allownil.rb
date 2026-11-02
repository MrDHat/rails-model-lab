# Expected credit 0.0: lets an explicit nil status through.
class Payment < ActiveRecord::Base
  enum :status, { pending: 0, settled: 10, failed: 20 }, prefix: true, default: :pending, validate: { allow_nil: true }
end
