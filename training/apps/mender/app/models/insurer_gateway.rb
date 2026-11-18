# Stand-in for the insurers' claims API. Tests read InsurerGateway.submitted.
# Insurers often answer busy during their nightly batch, which is raised as
# InsurerGateway::Busy; a claim they refuse raises InsurerGateway::Rejected.
module InsurerGateway
  class Busy < StandardError; end
  class Rejected < StandardError; end

  mattr_accessor :submitted, default: []
  mattr_accessor :busy_for, default: 0
  mattr_accessor :reject_next, default: false

  def self.submit(payload)
    if busy_for.positive?
      self.busy_for -= 1
      raise Busy, "insurer busy"
    end
    if reject_next
      self.reject_next = false
      raise Rejected, "member not covered"
    end
    submitted << payload
    "CLM-#{submitted.size.to_s.rjust(6, '0')}"
  end
end
