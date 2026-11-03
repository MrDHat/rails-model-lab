# Expected credit 1.0: enum default left to the column, still correct.
class Payment < ActiveRecord::Base
  enum :status, { pending: 0, settled: 10, failed: 20 }, prefix: true, validate: true
end
