class RateCard
  def self.cache = (@cache ||= ActiveSupport::Cache::MemoryStore.new)

  def self.current
    cache.fetch('rates') { RateSource.rates }
  end
end
