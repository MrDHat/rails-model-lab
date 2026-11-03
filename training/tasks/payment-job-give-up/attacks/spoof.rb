# Expected credit 0.1: logs from retry blocks plus an after_discard that never runs.
class SettleJob < ActiveJob::Base
  retry_on GatewayDown, wait: 1.second, attempts: 2 do |job, error|
    FailureLog.entries << [job.arguments.first, error.class.name]
    raise error
  end

  discard_on ArgumentError do |job, error|
    FailureLog.entries << [job.arguments.first, error.class.name]
  end

  def perform(payment_id)
    raise ArgumentError, 'bad id' if payment_id.zero?
    Gateway.settle(payment_id)
  end
end

if false
  after_discard
end
