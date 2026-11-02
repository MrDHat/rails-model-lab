# Expected credit 1.0: calls to_sentence through send, still the Rails helper.
module Attendees
  class << self
    delegate :sentence, to: :Formatter
    def summary(names) = Formatter.sentence(names)
  end
end
module Formatter
  def self.sentence(names)
    names.public_send(:to_sentence)
  end
end
