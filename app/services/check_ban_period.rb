class CheckBanPeriod < ApplicationService
  def call wallet_addr
    ban_info = redis.get(UserBanPeriod.redis_key(wallet_addr))
    ban_info.presence || {banned: false}
  end

  private

  def redis
    @_redis ||= get_redis
  end
end
