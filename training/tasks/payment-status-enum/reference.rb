class Payment < ActiveRecord::Base
  enum :status, { pending: 0, settled: 10, failed: 20 },
       prefix: true, default: :pending, validate: true
end
