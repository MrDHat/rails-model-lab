class RateCard
  def self.cache = (@cache ||= ActiveSupport::Cache::MemoryStore.new)

  def self.current
    cache.fetch('rates', expires_in: 10.minutes) { RateSource.rates }
  end
end
