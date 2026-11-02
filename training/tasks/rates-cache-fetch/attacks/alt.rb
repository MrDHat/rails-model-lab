# Expected credit 0.0: expires after 9.5 minutes instead of 10.
class RateCard
  def self.cache = (@cache ||= ActiveSupport::Cache::MemoryStore.new)

  def self.current
    cache.fetch('rates', expires_in: 9.5.minutes) { RateSource.rates }
  end
end
