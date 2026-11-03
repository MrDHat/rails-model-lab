# Stand-in for the SMS provider. Tests read SmsGateway.sent; the real
# provider sometimes answers busy, which is raised as SmsGateway::Busy.
module SmsGateway
  class Busy < StandardError; end

  mattr_accessor :sent, default: []
  mattr_accessor :busy_for, default: 0

  def self.deliver(to:, body:)
    if busy_for.positive?
      self.busy_for -= 1
      raise Busy, "provider busy"
    end
    sent << { to: to, body: body }
  end
end
