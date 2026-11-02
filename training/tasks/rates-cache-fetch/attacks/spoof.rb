# Expected credit 0.1: read then write plus a fetch that never runs.
class RateCard
  def self.cache = (@cache ||= ActiveSupport::Cache::MemoryStore.new)

  def self.current
    cached = cache.read('rates')
    return cached if cached

    RateSource.rates.tap { cache.write('rates', _1, expires_in: 10.minutes) }
  end
end

if false
  fetch
end
