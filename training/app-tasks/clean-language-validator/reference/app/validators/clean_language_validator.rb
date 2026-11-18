# Rejects text that uses one of the words we don't publish, as whole words in
# any capitalisation.
#
#   validates :body, clean_language: true
class CleanLanguageValidator < ActiveModel::EachValidator
  BANNED_WORDS = %w[scam idiot moron crook].freeze

  def validate_each(record, attribute, value)
    words = value.to_s.downcase.split(/\W+/)
    record.errors.add(attribute, options[:message] || "contains words we don't publish") if words.intersect?(BANNED_WORDS)
  end
end
