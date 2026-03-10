class SetBanPeriod < ApplicationService
  def call wallet_addr, game_id
    user_ban = UserBanPeriod.where(wallet_addr: wallet_addr).first_or_initialize
    user_ban.update(game_id: game_id, counter: (user_ban.counter + 1))

    ban_info = {
      banned: true,
      banned_until: user_ban.banned_until.to_i,
      counter: user_ban.counter
    }

    redis.set(UserBanPeriod.redis_key(wallet_addr), ban_info, ex: user_ban.ban_timeframe) if user_ban.ban_timeframe > 0
  end

  private

  def redis
    @_redis ||= get_redis
  end
end
