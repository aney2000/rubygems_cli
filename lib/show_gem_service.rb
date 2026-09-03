# frozen_string_literal: true

# Resolves gem details with two-day local cache.
class ShowGemService
  def initialize(api:, cache:)
    @api = api
    @cache = cache
  end

  def call(gem_name)
    cache_key = cache_key_for(gem_name)
    cached = @cache.read(cache_key)
    return cached unless cached.nil?

    fresh = @api.fetch_gem(gem_name)
    @cache.write(cache_key, fresh) unless fresh.nil?
    fresh
  end

  private

  def cache_key_for(gem_name)
    "gem:#{gem_name}"
  end
end
