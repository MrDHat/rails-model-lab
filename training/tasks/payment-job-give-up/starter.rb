class SettleJob < ActiveJob::Base
  retry_on GatewayDown, wait: 1.second, attempts: 2
  discard_on ArgumentError

  def perform(payment_id)
    raise ArgumentError, 'bad id' if payment_id.zero?
    Gateway.settle(payment_id)
  end
end
