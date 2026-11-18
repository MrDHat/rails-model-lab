# Stand-in for the SMS provider. Tests read SmsGateway.sent. Numbers must be
# E.164 ("+5511987654321"); the provider rejects anything else.
module SmsGateway
  class InvalidNumber < StandardError; end

  mattr_accessor :sent, default: []

  def self.deliver(to:, body:)
    raise InvalidNumber, "not an E.164 number: #{to.inspect}" unless to.to_s.match?(/\A\+\d{10,15}\z/)

    sent << { to: to, body: body }
  end
end
