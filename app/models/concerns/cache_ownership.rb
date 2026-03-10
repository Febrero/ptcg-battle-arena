module CacheOwnership
  extend ActiveSupport::Concern

  class_methods do
    def cache_ownership_prefix
      const_get(:CACHE_OWNERSHIP_PREFIX)
    end

    def ownership_last_updated_at_cache_key(wallet_addr)
      "#{cache_ownership_prefix}#{wallet_addr}::LastUpdatedAt"
    end

    # Updated ownership last updated per wallet_addr
    def update_ownership_last_updated_at(wallet_addr)
      Rails.cache.write(ownership_last_updated_at_cache_key(wallet_addr), Time.now.to_i, expires_in: 12.hours)
    end

    # Gets ownership last updated per wallet_addr
    def ownership_last_updated_at(wallet_addr)
      Rails.cache.fetch(ownership_last_updated_at_cache_key(wallet_addr), expires_in: 12.hours) do
        Time.now.to_i
      end
    end
  end
end
