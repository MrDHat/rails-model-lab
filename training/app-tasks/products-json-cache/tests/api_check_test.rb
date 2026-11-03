require "test_helper"

class ProductsJsonCacheApiTest < ActionDispatch::IntegrationTest
  # A repeat request is served by Rails.cache.fetch, which reports its hits.
  test "reads through the cache with Rails.cache.fetch" do
    Rails.cache.clear
    hits = 0
    counter = ->(*) { hits += 1 }
    ActiveSupport::Notifications.subscribed(counter, "cache_fetch_hit.active_support") do
      2.times { get api_products_path(api_key: api_key), as: :json }
    end
    assert_operator hits, :>=, 1, "the second request didn't come from Rails.cache.fetch"
  end
end
