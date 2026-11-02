class Payment < ActiveRecord::Base
  enum :status, [:pending, :settled, :failed], prefix: true
end
