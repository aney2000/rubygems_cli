# frozen_string_literal: true

# Retrieves search results from cache first and falls back to API.
class SearchGemsService
  def initialize(api:, cache:)
    @api = api
    @cache = cache
  end

  def call(query)
    cache_key = cache_key_for(query)
    cached = @cache.read(cache_key)
    return cached unless cached.nil?

    fresh = @api.search_gems(query)
    @cache.write(cache_key, fresh)
    fresh
  end

  private

  def cache_key_for(query)
    "search:#{query}"
  end
end
