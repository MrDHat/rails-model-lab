# Rejects text that uses one of the words we don't publish, as whole words in
# any capitalisation.
#
#   checks_language_of :body
module CleanLanguage
  extend ActiveSupport::Concern

  BANNED_WORDS = %w[scam idiot moron crook].freeze

  class_methods do
    def checks_language_of(*attributes)
      validate do
        attributes.each do |attribute|
          words = public_send(attribute).to_s.downcase.split(/\W+/)
          errors.add(attribute, "contains words we don't publish") if words.intersect?(BANNED_WORDS)
        end
      end
    end
  end
end
