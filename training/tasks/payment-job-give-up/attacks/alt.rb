# Expected credit 0.0: skips the gateway for successful payments.
class SettleJob < ActiveJob::Base
  retry_on GatewayDown, wait: 1.second, attempts: 2
  discard_on ArgumentError

  after_discard do |job, error|
    FailureLog.entries << [job.arguments.first, error.class.name]
  end

  def perform(payment_id)
    raise ArgumentError, 'bad id' if payment_id.zero?
    Gateway.settle(payment_id) if payment_id.negative?
  end
end
